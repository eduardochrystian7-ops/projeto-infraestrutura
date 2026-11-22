#!/usr/bin/env bash
set -euo pipefail
IP="${1:?Uso: $0 <IP-DA-VM>}"; OUT="$(cd "$(dirname "$0")/.." && pwd)/conf/tls"
mkdir -p "$OUT"; umask 077
openssl genrsa -out "$OUT/ca.key" 4096
openssl req -x509 -new -key "$OUT/ca.key" -sha256 -days 365 -subj '/CN=CA da Equipe' -out "$OUT/ca.crt"
openssl genrsa -out "$OUT/servico.key" 2048
openssl req -new -key "$OUT/servico.key" -subj '/CN=servico.lab' -out "$OUT/servico.csr"
printf 'subjectAltName=DNS:servico.lab,IP:%s\n' "$IP" > "$OUT/san.ext"
openssl x509 -req -in "$OUT/servico.csr" -CA "$OUT/ca.crt" -CAkey "$OUT/ca.key" -CAcreateserial -out "$OUT/servico.crt" -days 365 -sha256 -extfile "$OUT/san.ext"
echo "CA criada em $OUT/ca.crt; importe-a no navegador."

