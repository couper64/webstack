#!/usr/bin/env pwsh

Write-Host "Stopping and removing containers..."
docker compose -f ./hub/docker-compose.yml down --volumes --remove-orphans

Write-Host "Removing SSL folders..."
Remove-Item -Recurse -Force "hub/source/certificate_openssl/ssl/ca" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "hub/source/certificate_openssl/ssl/cert" -ErrorAction SilentlyContinue

Write-Host "Removing .env..."
Remove-Item -Force "hub/.env" -ErrorAction SilentlyContinue

Write-Host "Done! Everything is uninstalled."
