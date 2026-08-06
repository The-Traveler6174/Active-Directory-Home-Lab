# Export and Deploy a copy of: 
- server roles and features
- network config
- windows services 
- firewall rules
- regestry settings 
- scheduled tasks
- disk partitioning info
- installed software

## Export from Source Server
1. Run as Administrator: .\Export-ServerConfig.ps1
2. Copy entire ServerConfig folder

## Deploy to New Server
1. Copy ServerConfig folder to new server
2. Run as Administrator: .\Deploy-FullServerSetup.ps1 -IPAddress "192.168.1.X"
3. Restart server when prompted
4. Verify all services running
