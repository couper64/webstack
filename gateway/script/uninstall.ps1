#!/usr/bin/env pwsh

Write-Host "Stopping and removing containers..."
docker compose -f ./gateway/docker-compose.yml down --volumes --remove-orphans

Write-Host "Removing SSL folders..."
Remove-Item -Recurse -Force "gateway/source/certificate_openssl/ssl/ca" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "gateway/source/certificate_openssl/ssl/cert" -ErrorAction SilentlyContinue

Write-Host "Removing .env..."
Remove-Item -Force "gateway/.env" -ErrorAction SilentlyContinue

Write-Host "Done! Everything is uninstalled."
