# Check if script is being run as administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "This script must be run as an administrator. Please run PowerShell as an administrator and try again." -ForegroundColor Red
    exit 1
}

# Install IIS and necessary components
Write-Host "Installing IIS and necessary components..."
Install-WindowsFeature Web-Server, Web-Mgmt-Tools, Web-Mgmt-Console, Web-WebServer, Web-Common-Http, Web-Default-Doc, Web-Dir-Browsing, Web-Http-Errors, Web-Static-Content, Web-Health, Web-Http-Logging, Web-Log-Libraries, Web-Request-Monitor, Web-Performance, Web-Stat-Compression, Web-Security, Web-Filtering, Web-Windows-Auth, Web-App-Dev, Web-Net-Ext45, Web-Asp-Net45, Web-ISAPI-Ext, Web-ISAPI-Filter | Out-Null

# Restart IIS to apply changes
Write-Host "Restarting IIS..."
Restart-Service W3SVC

# Create a new website in IIS
Write-Host "Creating a new website in IIS..."
$websiteName = Read-Host "Enter website name"
$websitePath = Read-Host "Enter website path"
New-WebSite -Name $websiteName -PhysicalPath $websitePath -Port 80 -Force

# Create a test index.html file in the website directory
Write-Host "Creating a test index.html file..."
$html = "<html><body><h1>Welcome to $websiteName</h1></body></html>"
$html | Out-File "$websitePath\index.html" -Encoding utf8

# Open the website in a web browser
Write-Host "Opening website in web browser..."
Start-Process "http://localhost/$websiteName"
