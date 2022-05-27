#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

#Depending on the operating system of the host machines(s) that will build or run the containers, the image specified in the FROM statement may need to be changed.
#For more information, please see https://aka.ms/containercompat

#Setup Base .net core 6.0 with iis image to publish to with required ports open
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443
EXPOSE 5000
EXPOSE 5001

#Intermediary build container with full SDK
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
#Setup nuget package sources
WORKDIR /src
#Setup nuget package sources
COPY ["NuGet.Config", "."]
COPY ["Renderer.csproj", "."]
#Restore nuget packages
RUN dotnet restore "Renderer.csproj"
#Copy project folder
COPY . .
#Build project
RUN dotnet build "Renderer.csproj" -c Release -o /app/build

#Publish project for deployment
FROM build AS publish
RUN dotnet publish "Renderer.csproj" -c Release -o /app/publish

#Copy published files from sdk image to base image
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

#Start application
ENTRYPOINT ["dotnet", "Renderer.dll"]