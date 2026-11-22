# Arquitetura - Trilha B (API de tarefas)

```mermaid
flowchart LR
  N[Notebook do aluno] -->|8081 HTTP / 8444 HTTPS| H[VM cloud-lab: host LXD]
  H -->|dispositivo proxy LXD| P[proxy\n10.10.10.10\nnginx + interface]
  P -->|HTTP 8000| A[app\n10.10.10.11\nFastAPI]
  A -->|PostgreSQL 5432| D[db\n10.10.10.12\nPostgreSQL]
  V[(pool-final / vol-db)] --- D
  DEV[net-dev 10.10.20.0/24\ndev-proxy -> dev-app -> dev-db]
  ACL{{ACLs bloqueiam\nPROD <-> DEV}} --- DEV
  ACL --- P
```

| Camada | Responsabilidade | Exposição |
|---|---|---|
| proxy | Nginx, frontend estático e término TLS | Única camada publicada |
| app | Endpoints FastAPI e regra de negócio | Apenas rede privada |
| db | PostgreSQL com dados em `vol-db` | Apenas `app:5432` |

As redes `net-prod` e `net-dev` usam bridges distintas e NAT apenas para saída. As ACLs eliminam o roteamento entre elas. O volume tem ciclo de vida independente da instância, portanto o banco pode ser recriado sem perder os dados.

