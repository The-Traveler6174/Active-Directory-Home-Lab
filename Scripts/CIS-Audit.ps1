#region CIS Benchmark v2.1.0 - Windows Server 2025 Compliance Auditor

# Configuration
$CISVersion = "2.1.0"
$ServerOS = "Windows Server 2025"
$AuditDateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$auditResults = @()

function Write-AuditLog {
    param(
        [string]$Message,
        [string]$Level = "Info",
        [string]$ControlID = "",
        [string]$Status = ""
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $colors = @{
        "Success"   = "Green"
        "Warning"   = "Yellow"
        "Error"     = "Red"
        "Info"      = "Cyan"
    }
    
    $color = $colors[$Level]
    Write-Host "[$timestamp] [$Level] $ControlID - $Message" -ForegroundColor $color
    
    # Store results for reporting
    $script:auditResults += [PSCustomObject]@{
        DateTime      = $timestamp
        ControlID     = $ControlID
        Message       = $Message
        Level         = $Level
        Status        = $Status
    }
}

Write-Host "================================" -ForegroundColor Cyan
Write-Host "CIS Benchmark $CISVersion - $ServerOS Audit" -ForegroundColor Cyan
Write-Host "Started: $AuditDateTime" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

#region Section 1 - Account Policies

Write-Host "=== SECTION 1: ACCOUNT POLICIES ===" -ForegroundColor Magenta

# 1.1.1 - Enforce password history
try {
    $policy = Get-CimInstance -ClassName Win32_UserAccount -Filter "Name='Administrator'" -ErrorAction Stop
    $regPath = "HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters"
    
    $enforceHistory = Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters" `
        -Name "PasswordHistorySize" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty PasswordHistorySize
    
    # Check via Group Policy
    $pwdHistory = Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" `
        -ErrorAction SilentlyContinue
    
    Write-AuditLog "Checking password history enforcement" -Level "Info" -ControlID "1.1.1"
}
catch {
    Write-AuditLog "Error checking 1.1.1: $($_.Exception.Message)" -Level "Error" -ControlID "1.1.1"
}

# 1.1.5 - Password must meet complexity requirements
try {
    $complexity = secedit /export /cfg "$env:TEMP\secedit.cfg" /quiet 2>&1
    $secPolicy = Get-Content "$env:TEMP\secedit.cfg" | Select-String "PasswordComplexity"
    
    if ($secPolicy -match "PasswordComplexity\s*=\s*1") {
        Write-AuditLog "Password complexity requirements ENABLED" -Level "Success" -ControlID "1.1.5" -Status "PASS"
    } else {
        Write-AuditLog "Password complexity requirements NOT enforced" -Level "Warning" -ControlID "1.1.5" -Status "FAIL"
    }
    
    Remove-Item "$env:TEMP\secedit.cfg" -Force -ErrorAction SilentlyContinue
}
catch {
    Write-AuditLog "Error checking 1.1.5: $($_.Exception.Message)" -Level "Error" -ControlID "1.1.5"
}

#endregion

#region Section 2 - User Rights Assignment

Write-Host ""
Write-Host "=== SECTION 2: USER RIGHTS ASSIGNMENT ===" -ForegroundColor Magenta

# 2.2.23 - Deny log on as a batch job (include Guests)
try {
    $export = secedit /export /cfg "$env:TEMP\secedit.cfg" /quiet 2>&1
    $secPolicy = Get-Content "$env:TEMP\secedit.cfg"
    
    $batchJobDeny = $secPolicy | Select-String "SeDenyBatchLogonRight"
    
    if ($batchJobDeny -match "Guests") {
        Write-AuditLog "Guest batch job login denied" -Level "Success" -ControlID "2.2.23" -Status "PASS"
    } else {
        Write-AuditLog "Guest batch job login NOT properly restricted" -Level "Warning" -ControlID "2.2.23" -Status "FAIL"
    }
}
catch {
    Write-AuditLog "Error checking 2.2.23: $($_.Exception.Message)" -Level "Error" -ControlID "2.2.23"
}

# 2.2.25 - Deny log on locally (include Guests)
try {
    $secPolicy = Get-Content "$env:TEMP\secedit.cfg"
    $localLoginDeny = $secPolicy | Select-String "SeDenyInteractiveLogonRight"
    
    if ($localLoginDeny -match "Guests") {
        Write-AuditLog "Guest local login denied" -Level "Success" -ControlID "2.2.25" -Status "PASS"
    } else {
        Write-AuditLog "Guest local login NOT properly restricted" -Level "Warning" -ControlID "2.2.25" -Status "FAIL"
    }
}
catch {
    Write-AuditLog "Error checking 2.2.25: $($_.Exception.Message)" -Level "Error" -ControlID "2.2.25"
}

Remove-Item "$env:TEMP\secedit.cfg" -Force -ErrorAction SilentlyContinue

#endregion

#region Section 9 - Windows Firewall with Advanced Security

Write-Host ""
Write-Host "=== SECTION 9: WINDOWS FIREWALL ===" -ForegroundColor Magenta

try {
    $fwProfiles = Get-NetFirewallProfile -PolicyStore ActiveStore -ErrorAction Stop
    
    foreach ($profile in $fwProfiles) {
        $profileName = $profile.Name
        
        # 9.1.1 - Firewall enabled
        if ($profile.Enabled -eq $true) {
            Write-AuditLog "[$profileName] Firewall ENABLED" -Level "Success" -ControlID "9.1.1" -Status "PASS"
        } else {
            Write-AuditLog "[$profileName] Firewall DISABLED" -Level "Warning" -ControlID "9.1.1" -Status "FAIL"
        }
        
        # 9.1.2 - Default Inbound Action
        if ($profile.DefaultInboundAction -eq "Block") {
            Write-AuditLog "[$profileName] Inbound default action: BLOCK (Correct)" -Level "Success" -ControlID "9.1.2" -Status "PASS"
        } else {
            Write-AuditLog "[$profileName] Inbound default action: $($profile.DefaultInboundAction) (Should be Block)" -Level "Warning" -ControlID "9.1.2" -Status "FAIL"
        }
        
        # 9.1.3 - Default Outbound Action
        if ($profile.DefaultOutboundAction -eq "Allow") {
            Write-AuditLog "[$profileName] Outbound default action: ALLOW (Correct)" -Level "Success" -ControlID "9.1.3" -Status "PASS"
        } else {
            Write-AuditLog "[$profileName] Outbound default action: $($profile.DefaultOutboundAction) (Should be Allow)" -Level "Warning" -ControlID "9.1.3" -Status "FAIL"
        }
        
        # 9.1.5 - Log dropped packets
        Write-AuditLog "[$profileName] Log Dropped Packets: $($profile.LogDroppedPackets)" -Level "Info" -ControlID "9.1.5"
        
        # 9.1.6 - Log allowed packets
        Write-AuditLog "[$profileName] Log Allowed Packets: $($profile.LogAllowedPackets)" -Level "Info" -ControlID "9.1.6"
    }
}
catch {
    Write-AuditLog "Error checking firewall settings: $($_.Exception.Message)" -Level "Error" -ControlID "9.1.x"
}

#endregion

#region Section 18 - Windows Defender

Write-Host ""
Write-Host "=== SECTION 18: WINDOWS DEFENDER ===" -ForegroundColor Magenta

try {
    $defender = Get-MpComputerStatus -ErrorAction Stop
    
    # 18.1.1 - Real-time protection enabled
    if ($defender.RealTimeProtectionEnabled -eq $true) {
        Write-AuditLog "Real-time protection ENABLED" -Level "Success" -ControlID "18.1.1" -Status "PASS"
    } else {
        Write-AuditLog "Real-time protection DISABLED" -Level "Warning" -ControlID "18.1.1" -Status "FAIL"
    }
    
    # 18.1.3 - Behavior monitoring enabled
    if ($defender.BehaviorMonitoringEnabled -eq $true) {
        Write-AuditLog "Behavior monitoring ENABLED" -Level "Success" -ControlID "18.1.3" -Status "PASS"
    } else {
        Write-AuditLog "Behavior monitoring DISABLED" -Level "Warning" -ControlID "18.1.3" -Status "FAIL"
    }
    
    # Definition signatures age
    Write-AuditLog "Definition signatures last updated: $($defender.AntivirusSignatureLastUpdated)" -Level "Info" -ControlID "18.1.x"
}
catch {
    Write-AuditLog "Windows Defender not available or error occurred: $($_.Exception.Message)" -Level "Warning" -ControlID "18.1.x"
}

#endregion

#region Section 19 - Windows Update

Write-Host ""
Write-Host "=== SECTION 19: WINDOWS UPDATE ===" -ForegroundColor Magenta

try {
    # Check Windows Update service status
    $wuService = Get-Service -Name "wuauserv" -ErrorAction Stop
    
    if ($wuService.Status -eq "Running") {
        Write-AuditLog "Windows Update service RUNNING" -Level "Success" -ControlID "19.1" -Status "PASS"
    } else {
        Write-AuditLog "Windows Update service NOT running" -Level "Warning" -ControlID "19.1" -Status "FAIL"
    }
    
    # Check last update time
    $lastUpdateTime = Get-HotFix | Sort-Object -Property InstalledOn -Descending | Select-Object -First 1 -ExpandProperty InstalledOn
    Write-AuditLog "Last Windows Update installed: $lastUpdateTime" -Level "Info" -ControlID "19.1"
}
catch {
    Write-AuditLog "Error checking Windows Update: $($_.Exception.Message)" -Level "Error" -ControlID "19.1"
}

#endregion

#region Audit Summary Report

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "AUDIT SUMMARY" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

$passCount = ($auditResults | Where-Object { $_.Status -eq "PASS" }).Count
$failCount = ($auditResults | Where-Object { $_.Status -eq "FAIL" }).Count
$infoCount = ($auditResults | Where-Object { $_.Status -eq "" }).Count

Write-Host "PASSED:  $passCount" -ForegroundColor Green
Write-Host "FAILED:  $failCount" -ForegroundColor Red
Write-Host "CHECKED: $infoCount" -ForegroundColor Cyan

# Export results to CSV
$reportPath = "$PSScriptRoot\CIS-Audit-Report-$(Get-Date -Format 'yyyyMMdd-HHmmss').csv"
$auditResults | Export-Csv -Path $reportPath -NoTypeInformation -Force
Write-Host ""
Write-Host "Audit report saved to: $reportPath" -ForegroundColor Green

#endregion

#endregion
