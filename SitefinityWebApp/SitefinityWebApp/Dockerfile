#Set build container to correct .Net Framework SDK Version
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2019 AS build
WORKDIR /app

#Copy Files necessary to restore packages into container and then restore packages
COPY *.sln .
COPY nuget.config .
COPY SitefinityWebApp/SitefinityWebApp.csproj ./SitefinityWebApp/
COPY SitefinityWebApp/packages.config ./SitefinityWebApp/
RUN nuget restore 

# Copy Solution directory into build container
COPY . .
#Restore packages
RUN nuget restore 
#Build and publish Website
RUN msbuild c:/app/SitefinityWebApp/SitefinityWebApp.csproj /p:Configuration=Release -r:false 
RUN msbuild c:/app/SitefinityWebApp/SitefinityWebApp.csproj /p:DeployOnBuild=true /p:PublishProfile=FolderProfile.pubxml

#Set website container to run IIS and correct .Net Framework
FROM mcr.microsoft.com/dotnet/framework/aspnet:4.8-windowsservercore-ltsc2019 AS runtime 
WORKDIR /inetpub/wwwroot
#Copy files from build container to website container
COPY --from=build /app/SitefinityWebApp/obj/Docker/publish. ./
#Set Permissions on App Data Folder
RUN & ICACLS "'C:\inetpub\wwwroot\App_Data'  /grant 'IIS APPPOOL\DefaultAppPool:(OI)(CI)F' /T"

#Faster build startup.   Comment out all lines above and Publish from Visual Studio before building image
#FROM mcr.microsoft.com/dotnet/framework/aspnet:4.8-windowsservercore-ltsc2019 AS runtime 
#WORKDIR /inetpub/wwwroot
#COPY ./SitefinityWebApp/obj/Docker/publish. ./
#RUN & ICACLS "'C:\inetpub\wwwroot\App_Data'  /grant 'IIS APPPOOL\DefaultAppPool:(OI)(CI)F' /T"

#Enable Remote Debugging
#EXPOSE 4020 4021
#ADD https://aka.ms/vs/17/release/RemoteTools.amd64ret.enu.exe /VS_RemoteTools.exe
#RUN VS_RemoteTools.exe /install /quiet /norestart
#RUN del VS_RemoteTools.exe