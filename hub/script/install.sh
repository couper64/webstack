#!/bin/sh

set -e

echo "Creating SSL directory structure..."
mkdir -p hub/source/certificate_openssl/ssl/ca
mkdir -p hub/source/certificate_openssl/ssl/cert

ENV_FILE="hub/.env"
if [ -f "$ENV_FILE" ]; then
    echo ".env file already exists, skipping creation."
else
    echo "Creating .env file..."
    cat > "$ENV_FILE" << EOF
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

SUBJECT_CN=localhost
SUBJECT_ALT_NAME=DNS:localhost,IP:127.0.0.1

GUAC_POSTGRESQL_DATABASE=guacamole_db
GUAC_POSTGRESQL_PASSWORD='ChooseYourOwnPasswordHere1234'
GUAC_POSTGRESQL_USERNAME=guacamole_user
EOF
fi

echo "Pulling container images..."
docker compose -f ./hub/docker-compose.yml pull

echo "Building containers..."
docker compose -f ./hub/docker-compose.yml build

echo "Done! Containers built but not started."
