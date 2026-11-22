#!/usr/bin/env bash
set -euo pipefail
DB_HOST="$1"; DB_PASS="$2"
install -d -m 0755 /opt/tarefas
python3 -m venv /opt/tarefas/venv
/opt/tarefas/venv/bin/pip install --no-cache-dir fastapi 'uvicorn[standard]' psycopg2-binary
install -m 0644 /root/api.py /opt/tarefas/api.py
cat >/etc/systemd/system/tarefas.service <<EOF
[Unit]
Description=API de tarefas
After=network-online.target
[Service]
Environment=DB_HOST=$DB_HOST
Environment=DB_PASS=$DB_PASS
WorkingDirectory=/opt/tarefas
ExecStart=/opt/tarefas/venv/bin/uvicorn api:app --host 0.0.0.0 --port 8000
Restart=always
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable --now tarefas

