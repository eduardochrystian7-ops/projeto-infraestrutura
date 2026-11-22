#!/usr/bin/env bash
set -euo pipefail
ENV="${ENV:-prod}"; PROJETO="${PROJETO:-final-equipeN}"; ROOT="$(cd "$(dirname "$0")/.." && pwd)"
[ "$ENV" = prod ] && PREFIXO="" || PREFIXO=dev-
[ "$ENV" = prod ] && PORTA=8444 || PORTA=8445
for f in ca.crt servico.crt servico.key; do [ -f "$ROOT/conf/tls/$f" ] || { echo "Execute gerar-tls.sh primeiro"; exit 1; }; done
lxc --project "$PROJETO" file push "$ROOT/conf/tls/servico.crt" "${PREFIXO}proxy/etc/ssl/certs/servico.crt"
lxc --project "$PROJETO" file push "$ROOT/conf/tls/servico.key" "${PREFIXO}proxy/etc/ssl/private/servico.key" --mode 0600
APP_IP=$([ "$ENV" = prod ] && echo 10.10.10.11 || echo 10.10.20.11)
sed -e "s/__APP_IP__/$APP_IP/g" -e "s/__HTTPS_PORT__/$PORTA/g" "$ROOT/conf/nginx-tls.conf.tpl" > /tmp/nginx-tls.conf
lxc --project "$PROJETO" file push /tmp/nginx-tls.conf "${PREFIXO}proxy/etc/nginx/sites-available/servico"
lxc --project "$PROJETO" exec "${PREFIXO}proxy" -- bash -c 'nginx -t && systemctl reload nginx'
lxc --project "$PROJETO" config device add "${PREFIXO}proxy" porta-https proxy listen="tcp:0.0.0.0:$PORTA" connect=tcp:127.0.0.1:443

