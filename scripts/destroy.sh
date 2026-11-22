#!/usr/bin/env bash
set -euo pipefail
ENV="${ENV:-prod}"; PROJETO="${PROJETO:-final-equipeN}"; [ "$ENV" = prod ] && PREFIXO="" || PREFIXO=dev-
for i in proxy app db; do lxc --project "$PROJETO" delete -f "${PREFIXO}$i" 2>/dev/null || true; done
if [ "${1:-}" = --volumes ]; then lxc storage volume delete pool-final "${PREFIXO}vol-db" 2>/dev/null || true; fi
echo "Instancias removidas; volumes sao mantidos, salvo com --volumes."

