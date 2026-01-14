# Gateway

This folder exists to prepare a web stack that will act as an entry point, i.e. gateway, that will handle authentication & authorisation as well as secure public connection from internet to the hub. The connection between gateway and hub uses secure but internal connection.

Motivation is that access to the public internet changes over time and requires quick redeployment. Therefore, this gateway will act as a bloodhound for the central hub.

## Environment Variables (.env)

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
