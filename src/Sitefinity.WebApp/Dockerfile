#Hostname passed in as parameter from docker compose file
ARG hostname
#Set build container to correct .Net Framework SDK Version
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2019 AS build
WORKDIR /app
ENV HOSTNAME ${hostname}

# Copy Solution directory into build container
COPY ./Sitefinity.WebApp/ .
#Restore packages
RUN nuget restore 
#Build and publish Website
RUN msbuild c:/app/SitefinityWebApp.csproj /p:Configuration=Release -r:false 
RUN msbuild c:/app/SitefinityWebApp.csproj /p:DeployOnBuild=true /p:PublishProfile=FolderProfile.pubxml

#Set website container to run IIS and correct .Net Framework
FROM mcr.microsoft.com/dotnet/framework/aspnet:4.8-windowsservercore-ltsc2019 AS runtime 
WORKDIR /inetpub/wwwroot

#Copy files from build container to website container
COPY --from=build /app/obj/Docker/publish. ./

#Set options for IIS - https://www.progress.com/documentation/sitefinity-cms/133/configure-the-iis-to-host-sitefinity-projects

#Set Permissions on App Data Folder
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
RUN & ICACLS "'C:\inetpub\wwwroot\App_Data'  /grant 'IIS APPPOOL\DefaultAppPool:(OI)(CI)F' /T"

#Install WCF HTTP Activation
RUN powershell -Command Add-WindowsFeature NET-WCF-HTTP-Activation45 

#Setup Additional IIS Features if necessary uncomment next 2 lines 
#https://github.com/Sitefinity/docportal-resources/tree/master/Power%20Shell%20scripts
#ADD ./Sitefinity.WebApp/IIS10.ps1 /build/IIS10.ps1
#RUN powershell -File ‘/build/IIS10.ps1’ 

#Install URL Rewrite
WORKDIR /install
ADD https://download.microsoft.com/download/1/2/8/128E2E22-C1B9-44A4-BE2A-5859ED1D4592/rewrite_amd64_en-US.msi rewrite_amd64.msi
RUN Write-Host 'Installing URL Rewrite' ; \
    Start-Process msiexec.exe -ArgumentList '/i', 'rewrite_amd64.msi', '/quiet', '/norestart' -NoNewWindow -Wait

#Install self signed certificate for local development
#RUN powershell.exe -Command " \
#    Import-Module IISAdministration; \
#    $cert = New-SelfSignedCertificate -DnsName %hostname% -CertStoreLocation cert:\LocalMachine\My; \
#    $certHash = $cert.GetCertHash(); \
#    $sm = Get-IISServerManager; \
#    $sm.Sites[\"Default Web Site\"].Bindings.Add(\"*:443:\", $certHash, \"My\", \"0\"); \
#    $sm.CommitChanges();"


#Enable Remote Debugging
#EXPOSE 4020 4021
#ADD https://aka.ms/vs/17/release/RemoteTools.amd64ret.enu.exe /VS_RemoteTools.exe
#RUN VS_RemoteTools.exe /install /quiet /norestart
#RUN del VS_RemoteTools.exe