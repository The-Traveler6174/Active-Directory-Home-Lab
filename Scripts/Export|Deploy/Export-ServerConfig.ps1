# Export-ServerConfig.ps1
# Run as Administrator on your source server
# Make sure to copy C:\ServerConfig to a USB or network share folder

$ExportPath = "C:\ServerConfig"
New-Item -ItemType Directory -Path $ExportPath -Force | Out-Null

# 1. EXPORT INSTALLED ROLES AND FEATURES
Write-Host "Exporting roles and features..."
Get-WindowsFeature | Where-Object {$_.Installed} | `
    Select-Object Name, FeatureType | `
    Export-Csv -Path "$ExportPath\InstalledFeatures.csv" -NoTypeInformation

# 2. EXPORT NETWORK CONFIGURATION
Write-Host "Exporting network configuration..."
Get-NetIPConfiguration | Export-Clixml -Path "$ExportPath\NetworkConfig.xml"
Get-DnsClientServerAddress | Export-Clixml -Path "$ExportPath\DNSConfig.xml"

# 3. EXPORT WINDOWS SERVICES (which ones are running/enabled)
Write-Host "Exporting services configuration..."
Get-Service | Select-Object Name, StartType, Status | `
    Export-Csv -Path "$ExportPath\Services.csv" -NoTypeInformation

# 4. EXPORT FIREWALL RULES
Write-Host "Exporting firewall rules..."
Get-NetFirewallRule | Export-Clixml -Path "$ExportPath\FirewallRules.xml"

# 5. EXPORT REGISTRY SETTINGS (example: RDP settings)
Write-Host "Exporting registry settings..."
$RegPath = "HKLM:\System\CurrentControlSet\Control\Terminal Server"
reg export $RegPath "$ExportPath\TerminalServerReg.reg" /y

# 6. EXPORT SCHEDULED TASKS
Write-Host "Exporting scheduled tasks..."
Get-ScheduledTask | Where-Object {$_.TaskPath -notlike "\Microsoft\*"} | `
    ForEach-Object {
        Export-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath | `
            Out-File "$ExportPath\Task_$($_.TaskName -replace '\s+', '_').xml"
    }

# 7. EXPORT DISK PARTITIONING INFO
Write-Host "Exporting disk configuration..."
Get-Disk | Export-Clixml -Path "$ExportPath\DiskConfig.xml"
Get-Volume | Export-Clixml -Path "$ExportPath\VolumeConfig.xml"

# 8. EXPORT INSTALLED SOFTWARE (optional - requires DISM for built-in apps)
Write-Host "Exporting installed applications..."
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | `
    Select-Object DisplayName, DisplayVersion, InstallLocation | `
    Export-Csv -Path "$ExportPath\InstalledApps.csv" -NoTypeInformation

Write-Host "Export complete! Files saved to: $ExportPath"

Write-Host "Copying deployment scripts..."
Copy-Item -Path $PSScriptRoot\Deploy-ServerConfig.ps1 -Destination $ExportPath -Force
Copy-Item -Path $PSScriptRoot\ConfigureNetwork.ps1 -Destination $ExportPath -Force
Copy-Item -Path $PSScriptRoot\Deploy-FullServerSetup.ps1 -Destination $ExportPath -Force
Copy-Item -Path $PSScriptRoot\README.md -Destination $ExportPath -Force -ErrorAction SilentlyContinue

Write-Host "Export complete! Copy the entire ServerConfig folder to your new server."
Write-Host "Then run: .\Deploy-FullServerSetup.ps1 -IPAddress 'YOUR.NEW.IP'"
