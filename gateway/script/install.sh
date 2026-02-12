#!/bin/sh

set -e

echo "Creating SSL directory structure..."
mkdir -p gateway/source/certificate_openssl/ssl/ca
mkdir -p gateway/source/certificate_openssl/ssl/cert

ENV_FILE="gateway/.env"
if [ -f "$ENV_FILE" ]; then
    echo ".env file already exists, skipping creation."
else
    echo "Creating .env file..."
    cat > "$ENV_FILE" << EOF
KEYCLOAK_ADMIN=admin
KEYCLOAK_ADMIN_PASSWORD=admin

SUBJECT_CN=localhost
SUBJECT_ALT_NAME=DNS:localhost,IP:127.0.0.1

POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_DB=webservice
POSTGRES_USER=webservice
POSTGRES_PASSWORD=password

OIDC_CLIENT_ID=openresty-web-client
OIDC_CLIENT_SECRET=miKfPlLt0vK02UiaB3wp8mGohYZJU9F2
OIDC_ISSUER_PUBLIC=https://localhost:9990/iam/realms/myrealm
OIDC_ISSUER_INTERNAL=http://keycloak:8080/iam/realms/myrealm
OIDC_REDIRECT_URI=https://localhost:9990/redirect_uri
EOF
fi

echo "Pulling container images..."
docker compose -f ./gateway/docker-compose.yml pull

echo "Building containers..."
docker compose -f ./gateway/docker-compose.yml build

echo "Done! Containers built but not started."
