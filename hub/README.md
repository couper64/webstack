# Overview

This is Hub-related Docker Compose configuration. Noteworthy, the Celery worker of Hub doesn't use GPU/CUDA only CPU.

## Environment Variables

Create `hub/.env` with the following content.

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
    SUBJECT_ALT_NAME=DNS:localhost,IP:127.0.0.1,IP:192.168.0.30,DNS:kuil1.duckdns.org,IP:100.116.29.11

    GUAC_POSTGRESQL_DATABASE=guacamole_db
    GUAC_POSTGRESQL_PASSWORD='ChooseYourOwnPasswordHere1234'
    GUAC_POSTGRESQL_USERNAME=guacamole_user

## How to Save Existing Certificates

    clear ; docker run -it --rm -v hub_ca_data:/ca -v hub_cert_openresty_data:/cert -v ./proxy/ssl:/ssl alpine sh -c "cp /ca/* /ssl/ca/ ; cp /cert/* /ssl/cert/"

## How to Load Existing Certificates

If there is a backup of certificates on the host system. Then, use the command below to use the backup instead of newly generated certificates.

    docker compose down
    clear ; docker run -it --rm -v hub_ca_data:/ca -v hub_cert_openresty_data:/cert -v ./proxy/ssl:/ssl alpine sh -c "cp /ssl/ca/* /ca/ ; cp /ssl/cert/* /cert/"
    docker compose up --detach

# Remote

Create `./remote/.env` with the following minimum example content.

    GUAC_POSTGRESQL_DATABASE=guacamole_db
    GUAC_POSTGRESQL_PASSWORD='ChooseYourOwnPasswordHere1234'
    GUAC_POSTGRESQL_USERNAME=guacamole_user

Use the command below to individually run the service.

    cd remote
    docker compose up --build --detach

Use the command below to stop the service.

    cd remote
    docker compose down --volumes

# Tunnel

A service based on Ngrok.
