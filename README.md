# Webstack

A service (`./service`) for deployment of custom web services, a hub (`./hub`) to connect web services, and a gateway (`./gateway`) to expose web services to the internet.

# How to Copy

Once the computer is booted up and a user is logged in. Open a terminal to download the code and switch to the repo directory.

    git clone git@github.com:couper64/webstack.git webstack
    cd webstack

# How to Run

Below is a general overview of how to run this repo. Assuming the host has Docker installed. Actual commands are provided in the corresponding folders because commands might differ based on the configuration. However, they are based on a common idea:

1. Define your global settings/secrets in a local `.env` file. The file is used in `docker-compose.yml`.
2. Start the stack using the Docker Compose command inside the corresponding folder.
3. Leave it running as long as needed.
4. Shut down the stack using the Docker Compose command inside the corresponding folder.

# Architecture

![Architecture](documentation/image/architecture.jpg "System Architecture")

* FastAPI - acts as an API.
* Celery - acts as a task executor.
* Redis - acts as a queue manager.
* MinIO - acts as a file storage.
* Postgres - acts as a database.
* OpenResty - acts as a reverse proxy.
* Streamlit - acts as an example UI.

For the software to work, I had to assume a couple of things. Firstly, the software was developed for Ubuntu 24.04 OS as it is considered one of the most common and, perhaps, the easiest Linux distribution to obtain, maintain, and develop for. And, in my opinion, that ubiquity also helps passing down the software from one person to another. Secondly, the software is developed with Docker in mind, but native installation is also possible as an additional option. Thirdly, the operating system has been setup in a certain way that is documented in [this](https://vladislav.li/manual/) manual.

# Roadmap

- [x] Add support for FastAPI.
- [x] Add support for Celery and Redis.
- [x] Add support for Postgres and MinIO.
- [x] Add support for Docker Compose.
- [ ] Investigate if adding support for KeyCloak would benefit the project.
- [ ] Investigate if adding support for Grafana/Prometheus would benefit the project.
- [ ] Investigate if adding CodeCarbon to FastAPI would benefit the project. 
- [x] Add support for Flower to monitor Celery.
- [x] Make Lua scripts utilis environment variables instead of hardcoding values for username, password, database name, etc.

# Integration

This repository is used to ease both the development and integration. When a developer uses this project, they could develop on their own by deploying everything locally and ensure everything is operational. However, during the integration, the project is deployed on the cloud and accessed through a network.

# Docker Compose Commands Cheatsheet

The command below will build any updated images and start the containers in detached mode.

    docker compose up --build --detach

Run the command below in the same directory as your docker-compose.yml to stop and remove all containers, networks, and volumes created by the stack.

    docker compose down --volumes

Use command below to restart only that specific container without affecting the others.

    docker compose restart <service_name>

Add the new service definition to `docker-compose.yml` and run command below to start it without disrupting the rest.

    docker compose up --detach <service_name>

Use the command below to view the logs in real-time (`-f`).

    docker compose logs -f

To view an individual container in real-time (`-f`) use the command below.

    docker compose logs -f <service_name>
