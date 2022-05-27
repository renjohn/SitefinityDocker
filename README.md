# Sitefinity 14 CMS Docker for Local Development

This repository contains a docker implementation of the Sitefinity 14 with 3 tiers: database, cms backend, and cms frontend as their own containers.  This current implementation is intended only for local development, with the plans to evolve it to a full devops solution in the future.   This repository contains example compose files and associated configuration that we use internally at [Allegiance Group](https://www.teamallegiane.com).

The examples contained in this repo were designed to allow us to quickly get up and running on a Sitefinity instance for local development purposes on a Windows 10 machine.  The database container is running on a Linux container.  The SitefinityWebApp is running on a WindowsServerCore container, and the Renderer container is running on a Windows Nano container.  This is a blank instance running on the base Progress.Sitefinity packages need to run each solution.  If you need additional Sitefintity modules, you will need to add them via nuget prior to building the containers.

Some features:
- Container build for the Sitefinity 14 CMS backend that can be ported to older Sitefinity projects
- Options to use Visual Studio to build and publish the backend to the docker instance for faster development
- Persistent app_data folder to store logs and the sitefinity license
- Persistent sql_data folder for persistent database storage

Each topology is designed to work in isolation.

## Prerequisites

Hardware Requirements:
* 40GB Free space
  * Note: Can use less space by publishing backend from Visual Studio using Option 2 in the instructions below
* 16GB RAM

Software Requirements:
* Docker Desktop 4.x - Running on experimental mode to allow both Linux and Windows VMs to run side by side.  The Windows VM is required for the Sitefinity CMS backend.  
* Visual Studio 2019+
* Sitefinity License
* This was designed for use on a Windows machine but can easily be ported to MAC/Linux

## Directory Structure

* data
  * app_data - This directory maps to the Sitefinity Backend app_data directory where your license files,  configuration files, and log files are persistently stored
  * https - This data is for storage of generated ssl certificate
  * sql_data - This is directory is mounted to the container to store the sql database.  Your Sitefinity databases will be persisted here
* Renderer - Location of the Sitefinty Frontend solution.  This is where you will run the main docker topology from
* SitefinityWebApp - Location of the Sitefinity Backend solution.  This is where you can make any customizations for the backend of the product

## Getting Started

The renderer project is setup to only build the renderer container each time and rely on prebuilt backend containers for effeciency.  This project assumes that most of the work and customizations are contained in the front end Renderer project.  This requires that you build out the backend containers first.  The only time you will need to rebuild the backend contianers is for module installation, upgrades, and customizations to the backend cms.  If you are still developing modules and customizations for the backend, it is recommended you use option 2 below for faster development times.

### Option 1:
This option will pull the .NET SDK docker image to build the Sitefinity backend, and publish it to .NET Runtime docker image.  This is the "docker" way of doing things, but requires a lot more hard drive space and time to execute.  If you are doing a lot of development on the Sitefinity CMS backend or have limited drive space, please use Option 2.
1. Run `init.ps` in the root directory of the project.  This will build out the backend and frontend containers
2. Open the Renderer solution in Visual studio 
3. Switch the build context to Docker Compose
4. Debug the project using Docker Compose
5. Navigate to http://localhost:5000 to browse the site

### Option 2:
1. Open the SitefinityWebApp Solution
2. Open the Dockerfile
3. Comment lines 1-26
4. Uncomment lines 29-32
5. Save the file
6. Publish the SitefinityWebApp using the FolderPublish profile already in the project
7. Perform the steps in Option 1

## Custom Settings

The Docker Project Name is set in 2 places: one for the docker compose command line, one for the Visual Studio project.  This ensure that the container project namespace remains the same whether your run docker compose from the command line or from Visual Studio.  The command line variable COMPOSE_PROJECT_NAME is set in the Renderer/.env file.  The Visual Studio project name is set in the Renderer/docker-compose.dcproj file within the DockerComposeProjectName element.  It is recommended you update this variable for each project you run.

Memory Settings are set in the Renderer docker-compose.yml file as mem_limit 2GB for MySql, 8GB for the SitefinityWebApp backend.  You can increase/decrease the numbers based on your hardware situation.  I believe you need at least 1GB for MySql and 4GB for the backend.  You can also set a limit the same way for the Renderer.

## SSL

The containers are running on http vs https.  To enable https for the front end server you will need to go through a few steps.
1. Set useSSL to true in Renderer/Properties/launch.json
2. Uncomment line 33 in the Renderer/docker-compose.override.yml file
3.  Generate a certificate  with the following commands from the Renderer directory in Powershell.  Feel free to change the password "sitefinity14" in the commands.
    dotnet dev-certs https --clean
    dotnet dev-certs https -ep ..\data\https\renderer.pfx -p sitefinity14
    dotnet dev-certs https --trust
    dotnet user-secrets -p Renderer\Renderer.csproj set "Kestrel:Certificates:Development:Password" "sitefinity14"

This works, but required me to regenerate the SSL everytime the contianer was rebuilt even though the certificate was persisted.  It also required me to add/remove my volume mounts in my docker override as they tended to get sticky.  As this is for local development purposes, I turned of SSL to get rid of these annoyances. 

