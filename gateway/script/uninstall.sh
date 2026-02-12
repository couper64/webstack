#!/bin/sh

set -e

echo "Stopping and removing containers..."
docker compose -f ./gateway/docker-compose.yml down --volumes --remove-orphans

echo "Removing SSL folders..."
rm -rf gateway/source/certificate_openssl/ssl/ca
rm -rf gateway/source/certificate_openssl/ssl/cert

echo "Removing .env..."
rm -f gateway/.env

echo "Done! Everything is uninstalled."
