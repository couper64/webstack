#!/bin/sh
apk add --no-cache openssl
mkdir -p /ca

openssl req -x509 -newkey rsa:4096 -nodes \
  -keyout /ca/rootCA.key \
  -out /ca/rootCA.crt \
  -days 3650 \
  -subj '/CN=KUILCA' \
  -addext 'basicConstraints=critical,CA:TRUE' \
  -addext 'keyUsage=critical,keyCertSign,cRLSign'

echo "Certificate info (Basic Constraints & Key Usage):"
openssl x509 -in /ca/rootCA.crt -text -noout | grep -A1 'Basic Constraints\|Key Usage'

echo "CA ready, keeping container alive for 10 seconds."
sleep 10
