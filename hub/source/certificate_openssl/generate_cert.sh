#!/bin/sh
set -e

# Wait for CA certificate to appear
while [ ! -f /ca/rootCA.crt ]; do
  echo "Waiting for CA..."
  sleep 1
done

# Ensure certificate directory exists
mkdir -p /cert

# Generate server certificate if it doesn't exist
if [ ! -f /cert/openresty.crt ]; then
  echo "Generating server certificate..."

  # Install OpenSSL
  apk add --no-cache openssl

  # Generate private key
  openssl genrsa -out /cert/openresty.key 2048

  # Generate CSR with subject CN
  openssl req -new -key /cert/openresty.key \
    -out /cert/openresty.csr \
    -subj "/CN=${SUBJECT_CN}"

  # Create SAN configuration
  echo "subjectAltName=${SUBJECT_ALT_NAME}" > /tmp/san.cnf

  # Sign certificate using CA
  openssl x509 -req \
    -in /cert/openresty.csr \
    -CA /ca/rootCA.crt \
    -CAkey /ca/rootCA.key \
    -CAcreateserial \
    -out /cert/openresty.crt \
    -days 1095 \
    -sha256 \
    -extfile /tmp/san.cnf

  # Show SAN info from the generated certificate
  openssl x509 -in /cert/openresty.crt -text -noout | grep -A 1 "Subject Alternative Name"
else
  echo "Server cert already exists, skipping generation"
fi
