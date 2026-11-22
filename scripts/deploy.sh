#!/usr/bin/env bash
# Uso: DB_PASS='senha-forte' ENV=prod ./scripts/deploy.sh
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV="${ENV:-prod}"; PROJETO="${PROJETO:-final-equipeN}"; POOL="pool-final"; IMAGEM="ubuntu:24.04"
DB_PASS="${DB_PASS:?Defina DB_PASS sem espacos, aspas simples ou quebras de linha}"
if [ "$ENV" = prod ]; then REDE=net-prod; SUBNET=10.10.10; PORTA_HTTP=8081; PORTA_HTTPS=8444; PREFIXO=""; else REDE=net-dev; SUBNET=10.10.20; PORTA_HTTP=8082; PORTA_HTTPS=8445; PREFIXO=dev-; fi
LXC=(lxc --project "$PROJETO")

rede() { lxc network show "$REDE" >/dev/null 2>&1 || lxc network create "$REDE" ipv4.address="$SUBNET.1/24" ipv4.nat=true ipv6.address=none; }
storage() { lxc storage show "$POOL" >/dev/null 2>&1 || lxc storage create "$POOL" dir; lxc storage volume show "$POOL" "${PREFIXO}vol-db" >/dev/null 2>&1 || lxc storage volume create "$POOL" "${PREFIXO}vol-db"; }
perfis() { for p in perfil-base perfil-proxy perfil-app perfil-db; do lxc profile show "$p" >/dev/null 2>&1 || lxc profile create "$p"; lxc profile edit "$p" < "$ROOT/profiles/$p.yaml"; done; }
criar() { local nome="${PREFIXO}$1" ip="$2" papel="$3"; "${LXC[@]}" delete -f "$nome" 2>/dev/null || true; "${LXC[@]}" init "$IMAGEM" "$nome" -p perfil-base -p "$papel"; "${LXC[@]}" config device override "$nome" eth0 network="$REDE" ipv4.address="$ip"; }
iniciar() { "${LXC[@]}" start "${PREFIXO}$1"; "${LXC[@]}" exec "${PREFIXO}$1" -- cloud-init status --wait; }
push() { "${LXC[@]}" file push "$1" "${PREFIXO}$2"; }

main() {
  lxc project show "$PROJETO" >/dev/null 2>&1 || lxc project create "$PROJETO" -c features.images=false -c features.profiles=false
  rede; storage; perfis
  criar db "$SUBNET.12" perfil-db
  "${LXC[@]}" config device add "${PREFIXO}db" dados disk pool="$POOL" source="${PREFIXO}vol-db" path=/dados
  iniciar db; push "$ROOT/conf/config-postgres.sh" db/root/config-postgres.sh
  "${LXC[@]}" exec "${PREFIXO}db" -- bash /root/config-postgres.sh "$SUBNET.11" tarefas apiuser "$DB_PASS"
  criar app "$SUBNET.11" perfil-app; iniciar app
  push "$ROOT/conf/api.py" app/root/api.py; push "$ROOT/conf/instala-api.sh" app/root/instala-api.sh
  "${LXC[@]}" exec "${PREFIXO}app" -- bash /root/instala-api.sh "$SUBNET.12" "$DB_PASS"
  criar proxy "$SUBNET.10" perfil-proxy; iniciar proxy
  sed "s/__APP_IP__/$SUBNET.11/g" "$ROOT/conf/nginx-servico.conf.tpl" > /tmp/nginx-servico.conf
  push /tmp/nginx-servico.conf proxy/etc/nginx/sites-available/servico; push "$ROOT/conf/index.html" proxy/var/www/html/index.html
  "${LXC[@]}" exec "${PREFIXO}proxy" -- bash -c 'ln -sf /etc/nginx/sites-available/servico /etc/nginx/sites-enabled/servico; rm -f /etc/nginx/sites-enabled/default; nginx -t; systemctl reload nginx'
  "${LXC[@]}" config device add "${PREFIXO}proxy" porta-http proxy listen="tcp:0.0.0.0:$PORTA_HTTP" connect=tcp:127.0.0.1:80
  echo "Ambiente $ENV: http://<IP-DA-VM>:$PORTA_HTTP  (API: /api/saude)"
  echo "Para TLS, execute scripts/gerar-tls.sh e depois scripts/habilitar-tls.sh."
}
main "$@"

