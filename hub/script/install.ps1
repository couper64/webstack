#!/usr/bin/env pwsh

Write-Host "Creating SSL directory structure..."
New-Item -ItemType Directory -Force -Path "hub/source/certificate_openssl/ssl/ca" | Out-Null
New-Item -ItemType Directory -Force -Path "hub/source/certificate_openssl/ssl/cert" | Out-Null

$envFile = "hub/.env"
if (Test-Path $envFile) {
    Write-Host ".env file already exists, skipping creation."
} else {
    Write-Host "Creating .env file..."
@"
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_DB=webservice
POSTGRES_USER=webservice
POSTGRES_PASSWORD=password

MINIO_HOST_PREFIX=/
MINIO_ENDPOINT=minio:9000
MINIO_ROOT_USER=ROOTNAME
MINIO_ROOT_PASSWORD=CHANGEME123
MINIO_SECURE=false
MINIO_BUCKET_NAME=webservice

PGADMIN_DEFAULT_EMAIL=admin@admin.com
PGADMIN_DEFAULT_PASSWORD=admin

SUBJECT_CN=localhost
SUBJECT_ALT_NAME=DNS:localhost,IP:127.0.0.1
"@ | Set-Content -Path $envFile
}

Write-Host "Pulling container images..."
docker compose -f ./hub/docker-compose.yml pull

Write-Host "Building containers..."
docker compose -f ./hub/docker-compose.yml build

Write-Host "Done! Containers built but not started."
