# Overview

These are technologies that constitute a web stack. The purpose of the web stack is to provide a web service.

## Environment Variables

Create `template/.env` with the following content.

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

## How to Run

Make `.env` and use the command below to start the service.

    cd hub
    docker compose up --build --detach

Remove all services at once.

    docker compose down

## How to Test using Firefox Browser

To test SSL from a Firefox browser, run the command below to copy `rootCA.crt` and import it inside the browser, e.g. access `about:preferences#privacy` from address bar then using UI navigate to `Certificates/View Certificates/Authorities/Import...`.

    clear ; docker cp ca:/ca/* ./proxy/ssl/ca/

## How to Save Existing Certificates

    clear ; docker run -it --rm -v template_ca_data:/ca -v template_cert_openresty_data:/cert -v ./proxy/ssl:/ssl alpine sh -c "cp /ca/* /ssl/ca/ ; cp /cert/* /ssl/cert/"

## How to Load Existing Certificates

If there is a backup of certificates on the host system. Then, use the command below to use the backup instead of newly generated certificates.

    docker compose down
    clear ; docker run -it --rm -v template_ca_data:/ca -v template_cert_openresty_data:/cert -v ./proxy/ssl:/ssl alpine sh -c "cp /ssl/ca/* /ca/ ; rm /cert/*"
    docker compose up --detach

## How to Run using Native Commands

Once the project is cloned, the commands below will setup a `conda` environment.

    conda create -yn webservice python=3
    conda activate webservice
    pip install -r api/requirements.txt -r webui/requirements.txt -r worker/requirements.txt

Open a terminal in the `template` folder of the project and run the following command.

    fastapi dev api/main.py

To run `celery`, the following command will launch it from a terminal, in Windows.

> :warning: To run this command, additionally, install `eventlet`, e.g. `pip install eventlet`.

    celery -A worker.main worker --loglevel=info -P eventlet

On Linux, we could use a regular command.

    celery -A worker.main worker --loglevel=info

To setup `redis`, on Windows, it requires WSL2, by default, it is Ubuntu. The following should be run with Administrator privileges from PowerShell.

    wsl --update
    wsl --install

Inside Ubuntu, the following command should get us running.

    curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg

    echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list

    sudo apt-get update
    sudo apt-get install redis

    sudo service redis-server start

Once Redis is running, you can test it by running redis-cli:

    redis-cli

Test the connection with the ping command:

    127.0.0.1:6379> ping

Expected output is `PONG`.

To check the status of `redis-server.service`, on Linux and WSL.

    sudo systemctl status redis-server.service

# API

## Environment Variables

Create `template/api/.env` with the following content.

    MINIO_ENDPOINT=minio:9000
    MINIO_ROOT_USER=ROOTNAME
    MINIO_ROOT_PASSWORD=CHANGEME123
    MINIO_SECURE=false
    MINIO_BUCKET_NAME=webservice

## Folder Structure

Following the advices on the [official documentation](https://fastapi.tiangolo.com/tutorial/bigger-applications/), [GitHub](https://github.com/zhanymkanov/fastapi-best-practices?tab=readme-ov-file#project-structure), and [Medium](https://medium.com/@amirm.lavasani/how-to-structure-your-fastapi-projects-0219a6600a8f), the API is going to adhere to a microservice architecture. Thus, the top folder that contains most of the logic will be named `api` as per the [official documentation](https://fastapi.tiangolo.com/tutorial/bigger-applications/).

Knowing the internet, it will be updated and lost forever, so here is a copy of what the project structure is based on.

    .
    ├── api
    │   ├── __init__.py
    │   ├── main.py
    │   ├── dependencies.py
    │   └── routers
    │   │   ├── __init__.py
    │   │   ├── items.py
    │   │   └── users.py
    │   └── internal
    │       ├── __init__.py
    │       └── admin.py

## How to Test using Terminal

From PowerShell, the following command will create a task.

    clear ; Invoke-WebRequest -Uri "http://localhost:8000/task/sleep?duration=60" `
        -Method Post `
        -Headers @{ "Content-Type" = "application/json" }

From the Ubuntu terminal, the following command will create a task.

    curl -L -X POST "http://localhost:8000/task/sleep?duration=60" \
        -H "Content-Type: application/json"

From PowerShell, the following command will check the status of the task.

    clear ; Invoke-WebRequest -Uri "http://localhost:8000/task/e58f6e2c-cbab-4f62-921a-b404bb45172b" `
        -Method Get

From the Ubuntu terminal, the following command will check the status of the task.

    curl -X GET "http://localhost:8000/task/e58f6e2c-cbab-4f62-921a-b404bb45172b"

# Database

Use the command below to create a backup of a database (`webservice`) in `initdb.sql` as a `webservice` user. User and database name are dependant on the environment variable supplied in the `docker-compose.yml` file.

    clear ; docker compose exec postgres pg_dump -U webservice -d webservice --no-owner --no-privileges | Out-File -FilePath initdb.sql -Encoding utf8
    clear ; docker compose exec postgres pg_dump -U webservice -d webservice --no-owner --no-privileges > initdb.sql

## Default Postgres database
* Every Postgres installation has a default database called `postgres`.
* It exists mainly for administrative and internal purposes (you can connect to it, run queries, create other databases).
* You should not store application data in it.

# Proxy

A proxy service based on OpenResty.

There are 2 `nginx` configuration files because I wanted to showcase how an `openresty` could proxy services using SSL. In this example, the services are deployed on the same computer but it should be the same for services running on two different computers.

It is important to match names of a website with the arguments in the `printf 'subjectAltName=DNS:localhost,IP:127.0.0.1,DNS:openresty1' > /tmp/san.cnf &&` line inside `docker-compose.yml`. As you can see, I have added `DNS:openresty1` so that when I access it by `openresty1` inside `nginx_openresty2.conf` it would match the names for security purposes.

To test SSL from a Firefox browser, run the command below to copy `rootCA.crt` and import it inside the browser, e.g. access `about:preferences#privacy` from address bar then using UI navigate to `Certificates/View Certificates/Authorities/Import...`. Don't forget to create a folder: `mkdir ssl/ca && mkdir ssl/cert`.

    clear ; docker run -it --rm -v template_ca_data:/ca -v template_cert_openresty_data:/cert -v ./ssl:/ssl alpine sh -c "cp /ca/* /ssl/ca/ ; cp /cert/* /ssl/cert/"

If there is a backup of certificates on the host system. Then, use the command below to use backup instead of newly generated ones.

    clear ; docker run -it --rm -v template_ca_data:/ca -v template_cert_openresty_data:/cert -v ./proxy/ssl:/ssl alpine sh -c "cp /ssl/ca/* /ca/ ; cp /ssl/cert/* /cert/"
    clear ; docker run -it --rm -v template_ca_data:/ca -v template_cert_openresty1_data:/cert1 -v template_cert_openresty2_data:/cert2 -v ./ssl:/ssl alpine sh -c "cp /ssl/ca/* /ca/ ; rm /cert1/* ; rm /cert2/*"

The Docker Compose relies on `.env` with the following content example.

    POSTGRES_HOST=postgres
    POSTGRES_PORT=5432
    POSTGRES_DB=webservice
    POSTGRES_USER=webservice
    POSTGRES_PASSWORD=password

    SUBJECT_CN=localhost
    SUBJECT_ALT_NAME=DNS:localhost,IP:127.0.0.1

# Web UI

A service based on Streamlit.

# Worker

A service based on Celery & Redis.

The command below can be used to as a base to debug whether Worker container successfully found all Python packages or not.

    python
    from worker.task.classify import train_task

The commands below can be used to trigger tasks.

    clear ; celery -A main:worker call sleep_task --args='[5]'
    clear ; celery -A main:worker call train_task --args='[5, "model.pth"]'
    clear ; celery -A main:worker call infer_task --args='["tmpkrg7o6dc.zip", "model.pth"]'