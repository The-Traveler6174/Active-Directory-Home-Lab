# Deploy-ServerConfig.ps1
# Applies core Windows Server configurations from exported settings

param(
    [string]$ConfigPath = "C:\ServerConfig"
)

Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Starting server configuration..." -ForegroundColor Yellow

# ============================================================================
# Function: Log output with timestamp
# ============================================================================
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "HH:mm:ss"
    switch ($Level) {
        "INFO"    { Write-Host "[$timestamp] INFO $Message" -ForegroundColor Green }
        "WARNING" { Write-Host "[$timestamp] WARNING $Message" -ForegroundColor Yellow }
        "ERROR"   { Write-Host "[$timestamp] ERROR $Message" -ForegroundColor Red }
	}
}
# ============================================================================
# 1. Install Windows Features from Export
# ============================================================================
Write-Host "--- Installing Windows Features from Export ---" -ForegroundColor Cyan

$featuresFile = "$ConfigPath\InstalledFeatures.csv"
if (Test-Path $featuresFile) {
    try {
        $features = Import-Csv -Path $featuresFile
        Write-Log "Found $(($features | Measure-Object).Count) features to install"
        
        foreach ($feature in $features) {
            try {
                $state = (Get-WindowsFeature -Name $feature.Name -ErrorAction SilentlyContinue).InstallState
                if ($state -eq "Installed") {
                    Write-Log "$($feature.Name) - Already installed"
                } else {
                    Write-Log "Installing $($feature.Name)..."
                    Install-WindowsFeature -Name $feature.Name -IncludeManagementTools -WarningAction SilentlyContinue | Out-Null
                    Write-Log "$($feature.Name) installed successfully"
                }
            } catch {
                Write-Log "Failed to install $($feature.Name): $_" -Level "WARNING"
            }
        }
    } catch {
        Write-Log "Error reading features file: $_" -Level "ERROR"
    }
} else {
    Write-Log "Features export file not found at $featuresFile. Skipping." -Level "WARNING"
}

# ============================================================================
# 2. Configure Windows Services from Export
# ============================================================================
Write-Host "--- Configuring Windows Services from Export ---" -ForegroundColor Cyan

$servicesFile = "$ConfigPath\Services.csv"
if (Test-Path $servicesFile) {
    try {
        $services = Import-Csv -Path $servicesFile
        Write-Log "Found $(($services | Measure-Object).Count) services to configure"
        
        foreach ($svc in $services) {
            try {
                $service = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
                if ($service) {
                    Set-Service -Name $svc.Name -StartupType $svc.StartType -ErrorAction SilentlyContinue | Out-Null
                    Write-Log "Service $($svc.Name) startup type set to $($svc.StartType)"
                }
            } catch {
                Write-Log "Failed to configure service $($svc.Name): $_" -Level "WARNING"
            }
        }
    } catch {
        Write-Log "Error reading services file: $_" -Level "ERROR"
    }
} else {
    Write-Log "Services export file not found at $servicesFile. Skipping." -Level "WARNING"
}

# ============================================================================
# 3. Import Firewall Rules from Export
# ============================================================================
Write-Host "--- Importing Firewall Rules from Export ---" -ForegroundColor Cyan

$firewallFile = "$ConfigPath\FirewallRules.xml"
if (Test-Path $firewallFile) {
    try {
        Write-Log "Importing firewall rules from export..."
        $firewallRules = Import-Clixml -Path $firewallFile
        
        foreach ($rule in $firewallRules) {
            try {
                $existingRule = Get-NetFirewallRule -Name $rule.Name -ErrorAction SilentlyContinue
                if (-not $existingRule) {
                    New-NetFirewallRule -InputObject $rule | Out-Null
                    Write-Log "Imported firewall rule: $($rule.Name)"
                }
            } catch {
                Write-Log "Failed to import firewall rule $($rule.Name): $_" -Level "WARNING"
            }
        }
        Write-Log "Firewall rules import completed"
    } catch {
        Write-Log "Error importing firewall rules: $_" -Level "ERROR"
    }
} else {
    Write-Log "Firewall rules export file not found. Using default security settings." -Level "WARNING"
    
    # Apply default firewall settings
    try {
        Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled True | Out-Null
        Write-Log "Windows Firewall enabled for all profiles"
        
        Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -Direction Inbound | Out-Null
        Write-Log "Remote Desktop firewall rules enabled"
        
        Enable-NetFirewallRule -DisplayGroup "Windows Remote Management" -Direction Inbound | Out-Null
        Write-Log "WinRM firewall rules enabled"
    } catch {
        Write-Log "Error configuring default firewall: $_" -Level "ERROR"
    }
}

# ============================================================================
# 4. Import Terminal Server Registry Settings
# ============================================================================
Write-Host "--- Importing Terminal Server Settings ---" -ForegroundColor Cyan

$regFile = "$ConfigPath\TerminalServerReg.reg"
if (Test-Path $regFile) {
    try {
        Write-Log "Importing Terminal Server registry settings..."
        reg import $regFile | Out-Null
        Write-Log "Terminal Server registry settings imported"
    } catch {
        Write-Log "Error importing registry settings: $_" -Level "WARNING"
    }
} else {
    Write-Log "Registry export file not found. Configuring Remote Desktop manually." -Level "WARNING"
    
    try {
        Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' `
            -Name "fDenyTSConnections" -Value 0 | Out-Null
        Write-Log "Remote Desktop enabled"
        
        Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' `
            -Name "SecurityLayer" -Value 1 | Out-Null
        Write-Log "RDP security layer configured"
    } catch {
        Write-Log "Error configuring Remote Desktop: $_" -Level "WARNING"
    }
}

# ============================================================================
# 5. Import Scheduled Tasks from Export
# ============================================================================
Write-Host "--- Importing Scheduled Tasks from Export ---" -ForegroundColor Cyan

$taskFiles = Get-ChildItem -Path $ConfigPath -Filter "Task_*.xml" -ErrorAction SilentlyContinue
if ($taskFiles) {
    Write-Log "Found $(($taskFiles | Measure-Object).Count) scheduled tasks to import"
    
    foreach ($taskFile in $taskFiles) {
        try {
            Write-Log "Importing task from $($taskFile.Name)..."
            $taskXml = Get-Content -Path $taskFile.FullName -Raw
            Register-ScheduledTask -Xml $taskXml -TaskName $taskFile.BaseName -Force | Out-Null
            Write-Log "Task imported: $($taskFile.BaseName)"
        } catch {
            Write-Log "Failed to import task $($taskFile.Name): $_" -Level "WARNING"
        }
    }
} else {
    Write-Log "No scheduled task exports found. Skipping." -Level "WARNING"
}

# ============================================================================
# 6. Configure System Settings
# ============================================================================
Write-Host "--- Configuring System Settings ---" -ForegroundColor Cyan

try {
    Set-TimeZone -Name "UTC" -ErrorAction SilentlyContinue
    Write-Log "Timezone set to UTC"
    
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force | Out-Null
    Write-Log "PowerShell execution policy set to RemoteSigned"
    
    w32tm /config /manualpeerlist:"time.nist.gov" /syncfromflags:MANUAL /update | Out-Null
    net stop w32time /y | Out-Null
    net start w32time | Out-Null
    Write-Log "NTP configured and time service restarted"
} catch {
    Write-Log "Error configuring system settings: $_" -Level "WARNING"
}

# ============================================================================
# 7. Enable Event Logging
# ============================================================================
Write-Host "--- Configuring Event Logging ---" -ForegroundColor Cyan

try {
    Get-EventLog -List | Where-Object { $_.Log -eq "Security" } | ForEach-Object {
        if (-not $_.Enabled) {
            $_.Enabled = $true
            Write-Log "Security event log enabled"
        }
    }
    Write-Log "Event logging configured"
} catch {
    Write-Log "Error configuring event logging: $_" -Level "WARNING"
}

# ============================================================================
# 8. Summary and Recommendations
# ============================================================================
Write-Host "--- Configuration Summary ---" -ForegroundColor Cyan
Write-Log "Server configuration deployment completed"

$exportFiles = @{
    "InstalledFeatures.csv" = "Roles and Features"
    "Services.csv" = "Windows Services"
    "FirewallRules.xml" = "Firewall Rules"
    "TerminalServerReg.reg" = "Remote Desktop Settings"
    "Task_*.xml" = "Scheduled Tasks"
}

Write-Host "Configuration files processed:" -ForegroundColor Cyan
foreach ($file in $exportFiles.GetEnumerator()) {
    $exists = if (Test-Path "$ConfigPath\$($file.Name)" -ErrorAction SilentlyContinue) { "GOOD" } else { "BAD" }
}

Write-Host "Note: Some changes may require a server restart to take effect."
