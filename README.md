# Sitefinity CMS Docker for Local Development
## Current Sitefinity Version 14.2.7900 
This repository contains a docker implementation of the Sitefinity 14 with 3 tiers: database, cms backend, and cms frontend as their own containers. The implementation code structure is based on the Clean Architecture [Clean Architecture] (https://github.com/ardalis/CleanArchitecture) template from [Steve Smith](https://ardalis.com/).  This current implementation is intended only for local development, with the plans to evolve it to a full devops solution in the future.   This repository contains example compose files and associated configuration that we use internally at [Allegiance Group](https://www.teamallegiane.com).

The examples contained in this repo were designed to allow us to quickly get up and running on a Sitefinity instance for local development purposes on a Windows 10 machine.  The database container is running on a Linux container.  The SitefinityWebApp is running on a WindowsServerCore container, and the Renderer container is running on a Windows Nano container.  This is a blank instance running on the base Progress.Sitefinity packages need to run each solution.  If you need additional Sitefintity modules, you will need to add them via nuget prior to building the containers.

The implementation now also includes the setup of running ElasticSearch as the search technology using containers.  The code base is maintained by [Allegiance Group](https://www.teamallegiane.com).  There elasticsetup container creates security certificates for Elastic Search.  The es01 container is the Elastic Search instance.  There are also containers for Kibana and Enterprise search if you need them.

Some features:
- Container build for the Sitefinity 14 CMS backend that can be ported to older Sitefinity projects
- Clean architecture based on best practices from Microsoft
- Containers for Elastic Search
- Options to use Visual Studio to build and publish the backend to the docker instance for faster development
- Persistent app_data folder to store logs and the sitefinity license
- Persistent sql_data folder for persistent database storage

Each topology is designed to work in isolation.

## Prerequisites

Hardware Requirements:
* 40GB Free space
* 16GB RAM

Software Requirements:
* Docker Desktop 4.x - Running on experimental mode to allow both Linux and Windows VMs to run side by side.  The Windows VM is required for the Sitefinity CMS backend.  
  * Switch to Windows containers in Docker for Windows tray
  * Go to Docker Engine settings section and set experimental parameter to ‘true’
  * Add a json setting for DNS to allow internet access to windows containers - "dns": [ "8.8.8.8"]
* Visual Studio 2019+
  * Should be run in administrator mode to avoid issues
* Sitefinity License
* This was designed for use on a Windows machine 

## Directory Structure

* data - This is a persistent data directory for the solution at the root of the git repo that contain the following sub directories
  * app_data - This directory maps to the Sitefinity Backend app_data directory where your license files,  configuration files, and log files are persistently stored
  * certs - This directory maps to the elasticsetup container and is used to build and extract certificates for the elasticsearch containers.  To regenerate certificates, you will need to delete all the files in this directory
  * elasticsearch - This folder persists the configs and index of es01 Elastic Search container
  * enterprisesearch - This folder persists the configs and index of enterprisesearch Enterprise Search container
  * kibana - This folder persists the configs and index of kibana Kibana container
  * sql_data - This is directory is mounted to the container to store the sql database.  Your Sitefinity databases will be persisted here
* devops - This folder contains all the docker compose files for building the containers to host the application
* src - This folder contains all the projects used to develop and run the application
  * Sitefinity.Core - The core project that will contain the core application logic
  * Sitefinity.Infrastructure - The infrastructure project will contain dependecies to external systems
  * Sitefinity.ShareKernel - The shared kernel project will contain shared objects that need to be used throughut the application
  * Renderer - Location of the Sitefinty Frontend solution.  This is where you will run the main docker topology from
  * SitefinityWebApp - Location of the Sitefinity Backend solution.  This is where you can make any customizations for the backend of the product
* tests - This folder contains all the test projects
  * Sitefinity.FunctionalTests - Contains functional tests to test the application
  * Sitefinity.IntegrationTests - Contains integrations tests for the application and infrastructure
  * Sitefinity.UnitTests - Contains unit tests for the application

## Getting Started

The Renderer project is setup to only build the sitefinityrenderer container each time and rely on prebuilt backend containers for effeciency.  This project assumes that most of the work and customizations are contained in the front end Renderer project.  This requires that you build out the backend containers first.  The only time you will need to rebuild the backend contianers is for module installation, upgrades, and customizations to the backend cms.  

### Developing and Debugging the project using Visual Studio and Docker:

These direction are for developing within Visual Studio and debugging using Docker compose from within Visual Studio.  
1. Create .env file based off of the .env.example file in the root of the solution
2. Update the CHANGEME references in the file to whatever you want
3. Update the value of ENCRYPTION_KEYS to a 32 character string 
4. Create data/kibana/kibana.yml file from the data/kibana/kibana.yml.example file
5. Replace the <COPY_KIBANA_PASSWORD_from_ENV_FILE> text in the data/kibana/kibana.xml file with the the KIBANA_PASSWORD you updated in the .env file
4. Replace all the "<COPY_ENCRYPTION_KEYS_from_ENV_FILE>" text in the data/kibana/kibana.xml with the value of ENCRYPTION_KEYS in the .env file 
6. Run `.\buildsitefinitybackend.ps1` from the command line in the root directory of the solution.  This will build out the backend SitefinityWebApp container
    * Watch for any errors and you will need to troubleshoot them before continuing on
7. Open the Sitefinity.sln solution in Visual studio 
8. Switch the build configuration to docker compose
9. Debug the project using Docker Compose
    * Use Sitefinity launch setting to run the website without Elastic Search (3 less containers running)
    * Use Sitefinity with Elastic Search to run the website with the Elastic Search containers
10. Navigate to https://localhost:5001 to browse the site

### Sitefinity Initialization

The first time you spin up your container you will need to enter values for your local instance
1. Project Startup - Choose activate a license file that you have downloaded.
    * The license file will be provided by the Tech Lead
2. Database Settings
    * MS SQL Server
    * Server:  sitefinitysql
    * Port: 1433
    * Password:  See .env file in root of solution
    * Database Name: sitefinity
3. Register yourself as the administrator

### Local Elastic Search Development

Docker containers for Elastic Search, Kibana, and Enterprise Search are configure in the docker compose file.  They are disabled in the launch settings for Docker Compose within Visual Studio.  To run the full solution with the containers for elastic search you will need to change the Launch Settings to Docker Compose with Elasticsearch within Visual Studio.  This will setup the certificates and launch all 3 containers for Elastic Search to work locally.  You will also need to switch the search index within the Sitefinity Backend to use Elastic Search.  
  * Elastic Server: es01:9200
  * Elastic User: elastic
  * Elastic Password: See .env file in root of Solution

## Upgrade Procedures

1. Upgrade the Sitefinity Web App solution using the Sitefinity CLI
    * ex:   sf upgrade "SitefinityWebApp\SitefinityWebApp.sln" "14.2.7900" --acceptLicense
2. Use the nuget package manager to update the Renderer solution to match
3. Update the version numbers in the docker compose files in both the SitefinityWebApp and Renderer folders
4. Re-run `.\buildsitefinitybackend.ps1` from the root directory to rebuild the SitefinityWebApp container

## Custom Settings

Memory Settings are set in the Renderer docker-compose.yml or .env file as mem_limit 2GB for MySql, 8GB for the SitefinityWebApp backend.  You can increase/decrease the numbers based on your hardware situation.  You need at least 1GB for MySql and 4GB for the backend.  You can also set a limit the same way for the Renderer.

## Trouble Shooting

Ensure you are running Docker Desktop in Windows Container mode
Ensure you have experimental set to true in the Docker Desktop Settings
If you get container failed to start or stop - run 'docker compose down' in the Renderer directory.  You may need to do it more than once.
If you get errors regarding symlinks and can't start Docker Desktop, you may need to clear out your docker data directory using https://github.com/moby/docker-ci-zap

Error that you may run into when running `.\buildsitefinitybackend.ps1`
Status: hcsshim::PrepareLayer - failed failed in Win32: Incorrect function. (0x1), Code: 1

This may occur because of another background application that does file sharing. These include Dropbox, One Drive, and others. In some cases Adobe Creative Cloud and Cisco applications may be colliding.
The recommended steps are to first uninstall any of these applications. If you can not uninstall one, use the task manager to bring up the Start Up applications. Disable any file sharing processes and reboot.

Some articles will say to delete or rename the file(s) cbfsconnect2017.sys or cbfs6.sys but the above step seems to be more reliable.
 
