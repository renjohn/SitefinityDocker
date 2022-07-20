#Build the backend container
docker compose -f docker-compose-sitefinitywebapp.yml -f docker-compose-sitefinitywebapp.override.yml build

