#!/bin/sh

set -e

echo "Stopping and removing containers..."
docker compose -f ./service/docker-compose.yml down --volumes --remove-orphans

echo "Removing SSL folders..."
rm -rf service/source/certificate_openssl/ssl/ca
rm -rf service/source/certificate_openssl/ssl/cert

echo "Removing .env..."
rm -f service/.env

echo "Done! Everything is uninstalled."
