# Deploy-FullServerSetup.ps1
# Master script - runs all configuration steps in order

param(
    [string]$ConfigPath = "C:\ServerConfig",
    [string]$IPAddress,
    [string]$DNSServers = "8.8.8.8,8.8.4.4"
)

Write-Host "=======================================" -ForegroundColor Cyan
Write-Host " Windows Server Configuration Deployer " -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan

# Check if running as admin
$admin = [Security.Principal.WindowsIdentity]::GetCurrent().Groups -contains `
    [Security.Principal.SecurityIdentifier]'S-1-5-32-544'

if (-not $admin) {
    Write-Error "This script must run as Administrator!"
    exit 1
}

# Import and execute deployment
& "$ConfigPath\Deploy-ServerConfig.ps1" -ConfigPath $ConfigPath

# Configure network if IP provided
if ($IPAddress) {
    & "$ConfigPath\ConfigureNetwork.ps1" `
        -IPAddress $IPAddress `
        -DNSServers @($DNSServers -split ',')
}

Write-Host "All configurations applied!" -ForegroundColor Green
Write-Host "Server restart may be required for some changes to take effect."
