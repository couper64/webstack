Install `certbot` with Duck DNS plugin.

```
clear ; conda create -yn duckdns python=3
conda activate duckdns
pip install certbot_dns_duckdns
```

Run `certbot` with elevated privileges because it needs to access permitted folders.

```
clear ; sudo $(which certbot) certonly \
  --non-interactive \
  --agree-tos \
  --email <email> \
  --preferred-challenges dns \
  --authenticator dns-duckdns \
  --dns-duckdns-token <token> \
  --dns-duckdns-propagation-seconds 60 \
  -d <domain>.duckdns.org
```

Setup files for Fast Reverser Proxy (FRP) server, i.e. `frps.toml`. The other part is on the `stella`'s workstation inside the `dev` VM.

```
bindPort = 7000
vhostHTTPPort = 8989
```

The command below was used to run the server.

```
clear ; ./frps -c frps.toml
```

Run this to retrieve certificates.

On Linux:

```
docker compose run --rm \
  --entrypoint "certbot" \
  certbot \
  certonly \
  --non-interactive \
  --agree-tos \
  --email <email> \
  --preferred-challenges dns \
  --authenticator dns-duckdns \
  --dns-duckdns-token "<token>" \
  --dns-duckdns-propagation-seconds 900 \
  -d <domain>.duckdns.org
```

On Windows (PowerShell)

```
docker compose run --rm `
  --entrypoint "certbot" `
  certbot `
  certonly `
  --non-interactive --agree-tos --email <email> `
  --preferred-challenges dns --authenticator dns-duckdns `
  --dns-duckdns-token <token> `
  --dns-duckdns-propagation-seconds 900 `
  -d <domain>.duckdns.org
```