# ConfigureNetwork.ps1
# Configures network settings from export or manual parameters

param(
    [string]$IPAddress,
    [string[]]$DNSServers,
    [string]$Gateway,
    [int]$PrefixLength = 24,
    [string]$InterfaceAlias = "Ethernet",
    [string]$ConfigPath = "C:\ServerConfig",
    [switch]$UseExportedConfig
)

Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Starting network configuration..." -ForegroundColor Yellow

# ============================================================================
# Function: Log output with timestamp
# ============================================================================
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "HH:mm:ss"
    switch ($Level) {
        "INFO"    { Write-Host "[$timestamp] ✓ $Message" -ForegroundColor Green }
        "WARNING" { Write-Host "[$timestamp] ⚠ $Message" -ForegroundColor Yellow }
        "ERROR"   { Write-Host "[$timestamp] ✗ $Message" -ForegroundColor Red }
    }
}

# ============================================================================
# Function: Validate IP Address
# ============================================================================
function Test-IPAddress {
    param([string]$IP)
    try {
        [System.Net.IpAddress]::Parse($IP) | Out-Null
        return $true
    } catch {
        return $false
    }
}

# ============================================================================
# 1. Load Network Configuration from Export (if flag is set)
# ============================================================================
Write-Host "--- Loading Network Configuration ---" -ForegroundColor Cyan

if ($UseExportedConfig) {
    $networkConfigFile = "$ConfigPath\NetworkConfig.xml"
    $dnsConfigFile = "$ConfigPath\DNSConfig.xml"
    
    if (Test-Path $networkConfigFile) {
        try {
            Write-Log "Loading network configuration from export..."
            $exportedNetConfig = Import-Clixml -Path $networkConfigFile
            
            # Extract settings from export (these are complex objects, so we'll use them as reference)
            Write-Log "Network configuration loaded from export"
        } catch {
            Write-Log "Error loading network config: $_" -Level "WARNING"
        }
    } else {
        Write-Log "Network config export not found at $networkConfigFile" -Level "WARNING"
    }
    
    if (Test-Path $dnsConfigFile) {
        try {
            Write-Log "Loading DNS configuration from export..."
            $exportedDnsConfig = Import-Clixml -Path $dnsConfigFile
            Write-Log "DNS configuration loaded from export"
        } catch {
            Write-Log "Error loading DNS config: $_" -Level "WARNING"
        }
    }
}

# ============================================================================
# 2. Allow Manual Override or Use Default if Not Provided
# ============================================================================
if (-not $IPAddress) {
    Write-Log "No IP address provided. Please specify -IPAddress parameter." -Level "WARNING"
    Write-Host "`nUsage Examples:" -ForegroundColor Yellow
    Write-Host "  .\ConfigureNetwork.ps1 -IPAddress 192.168.1.50 -DNSServers '8.8.8.8','8.8.4.4'"
    Write-Host "  .\ConfigureNetwork.ps1 -IPAddress 10.0.0.100 -Gateway 10.0.0.1 -PrefixLength 24"
    exit 1
}

if (-not $DNSServers) {
    $DNSServers = @("8.8.8.8", "8.8.4.4")
    Write-Log "Using default DNS servers: $($DNSServers -join ', ')"
}

if (-not $Gateway) {
    $Gateway = "192.168.1.1"
    Write-Log "Using default gateway: $Gateway"
}

# ============================================================================
# 3. Validate Parameters
# ============================================================================
Write-Host "--- Validating Network Parameters ---" -ForegroundColor Cyan

if (-not (Test-IPAddress -IP $IPAddress)) {
    Write-Log "Invalid IP address format: $IPAddress" -Level "ERROR"
    exit 1
}
Write-Log "IP address validation: $IPAddress ✓"

foreach ($dns in $DNSServers) {
    if (-not (Test-IPAddress -IP $dns)) {
        Write-Log "Invalid DNS server address: $dns" -Level "WARNING"
    }
}

if (-not (Test-IPAddress -IP $Gateway)) {
    Write-Log "Invalid Gateway address: $Gateway" -Level "WARNING"
}

# ============================================================================
# 4. Find Network Adapter
# ============================================================================
Write-Host "--- Finding Network Adapter ---" -ForegroundColor Cyan

try {
    $adapter = Get-NetAdapter -Name $InterfaceAlias -ErrorAction Stop
    Write-Log "Found adapter: $($adapter.Name) (MAC: $($adapter.MacAddress))"
} catch {
    Write-Log "Adapter '$InterfaceAlias' not found. Listing available adapters:" -Level "WARNING"
    Get-NetAdapter | Select-Object Name, InterfaceDescription, Status | Format-Table
    
    $adapters = Get-NetAdapter | Select-Object -ExpandProperty Name
