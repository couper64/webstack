#!/bin/sh

set -e

echo "Stopping and removing containers..."
docker compose -f ./hub/docker-compose.yml down --volumes --remove-orphans

echo "Removing SSL folders..."
rm -rf hub/source/certificate_openssl/ssl/ca
rm -rf hub/source/certificate_openssl/ssl/cert

echo "Removing .env..."
rm -f hub/.env

echo "Done! Everything is uninstalled."
