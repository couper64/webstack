#!/bin/sh

mkdir -p /ca

# Only generate CA if it doesn't exist
if [ ! -f /ca/rootCA.crt ] || [ ! -f /ca/rootCA.key ]; then
  echo "Generating CA..."
  apk add --no-cache openssl
  openssl req -x509 -newkey rsa:4096 -nodes \
    -keyout /ca/rootCA.key \
    -out /ca/rootCA.crt \
    -days 3650 \
    -subj '/CN=KUILCA' \
    -addext 'basicConstraints=critical,CA:TRUE' \
    -addext 'keyUsage=critical,keyCertSign,cRLSign'

  echo "Certificate info (Basic Constraints & Key Usage):"
  openssl x509 -in /ca/rootCA.crt -text -noout | grep -A1 'Basic Constraints\|Key Usage'
else
  echo "CA already exists. Skipping generation."
fi
