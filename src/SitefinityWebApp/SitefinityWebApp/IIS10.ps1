#Modified version of https://github.com/Sitefinity/docportal-resources/tree/master/Power%20Shell%20scripts
$ErrorActionPreference  = "Stop";
        
write-host "Starting setup�" -foregroundcolor yellow;

$features = @(
"IIS-IIS6ManagementCompatibility",
"IIS-Metabase",
"IIS-ManagementScriptingTools",
"IIS-ManagementService",
"IIS-DefaultDocument",
"IIS-DirectoryBrowsing",
"IIS-HttpErrors",
"IIS-HttpRedirect",
"IIS-StaticContent",
"IIS-CGI",
"IIS-ISAPIExtensions",
"IIS-ISAPIFilter",
"IIS-WebDAV",
"IIS-CustomLogging",
"IIS-HttpLogging",
"IIS-LoggingLibraries",
"IIS-ODBCLogging",
"IIS-RequestMonitor",
"IIS-HttpTracing",
"IIS-HttpCompressionStatic",
"IIS-HttpCompressionDynamic",
"IIS-BasicAuthentication",
"IIS-WindowsAuthentication",
"IIS-DigestAuthentication",
"IIS-ClientCertificateMappingAuthentication",
"IIS-IISCertificateMappingAuthentication",
"IIS-RequestFiltering",
"IIS-IPSecurity",
"IIS-URLAuthorization",
"WAS-WindowsActivationService ",
"WAS-ProcessModel",
"WAS-ConfigurationAPI",
"IIS-ManagementConsole",
"IIS-HostableWebCore",
"IIS-WebServerRole",
"IIS-WebServer",
"IIS-CommonHttpFeatures",
"IIS-ApplicationDevelopment",
"IIS-Security",
"IIS-HealthAndDiagnostics",
"IIS-Performance",
"IIS-WebServerManagementTools",
"IIS-ServerSideIncludes",
"IIS-WMICompatibility"
)
$restartRequired = $false

Write-Host "Installing features..." -ForegroundColor Yellow;

foreach($feature in $features)
{
    Write-Host "Installing Feature: $feature" -ForegroundColor Gray
    $result = Enable-WindowsOptionalFeature -Online -FeatureName $feature -All    
    if($result.RestartNeeded)
    {
        $restartRequired = $true
    }
}

Write-Host "Features installed." -ForegroundColor Green;

#Register ASP.NET 4.0 with IIS

#Write-Host "Registering ASP.NET 4.0 with IIS…" -ForegroundColor Yellow;
#Start-Process -FilePath $aspnetRegIISFullName  -Argumentlist "-iru";

Write-Host "Setup complete." -ForegroundColor Green;

if($restartRequired)
{
    Write-Warning "Windows Features installation requires a restart to finish installing. Please reboot your machine."
}
