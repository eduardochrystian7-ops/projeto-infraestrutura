# Projeto final - Nuvem privada LXD

Implementação da **trilha B** do roteiro: uma API de tarefas com FastAPI e PostgreSQL. A arquitetura completa está em [docs/arquitetura.md](docs/arquitetura.md).

## Pré-requisitos

- VM Ubuntu com LXD configurado, 4 GB livres e acesso à Internet;
- usuário com permissão para executar `lxc`;
- uma senha de banco segura. Ela é fornecida em execução, nunca gravada no Git.

Substitua `final-equipeN` pelo número real da equipe exportando `PROJETO`.

## Subir PROD e DEV

```bash
cd projeto-infraestrutura
chmod +x scripts/*.sh
export PROJETO=final-equipe<N>
DB_PASS='uma-senha-segura' ENV=prod ./scripts/deploy.sh
DB_PASS='uma-senha-segura' ENV=dev  ./scripts/deploy.sh
```

PROD publica HTTP em `http://<IP-DA-VM>:8081`; DEV, em `:8082`. A API tem `GET /api/saude`, `GET/POST /api/tarefas`, `PATCH/DELETE /api/tarefas/{id}`. Os dados do PostgreSQL ficam em `pool-final/vol-db` (ou `dev-vol-db`).

## TLS e isolamento

```bash
./scripts/gerar-tls.sh <IP-DA-VM>
ENV=prod ./scripts/habilitar-tls.sh
```

Importe `conf/tls/ca.crt` no navegador e abra `https://<IP-DA-VM>:8444`. Os arquivos privados são ignorados pelo Git.

Para bloquear explicitamente o tráfego entre os ambientes:

```bash
lxc network acl create acl-prod
lxc network acl rule add acl-prod ingress action=drop source=10.10.20.0/24
lxc network acl rule add acl-prod egress action=drop destination=10.10.20.0/24
lxc network set net-prod security.acls=acl-prod
lxc network set net-prod security.acls.default.ingress.action=allow
lxc network set net-prod security.acls.default.egress.action=allow
```

Repita com `acl-dev`, invertendo as sub-redes, conforme o roteiro.

## Backup, restauração e operação

Antes de restaurar, pare o banco. Snapshot da instância e volume são operações separadas:

```bash
lxc --project "$PROJETO" snapshot db snap-instancia
lxc storage volume snapshot pool-final vol-db snap-volume
lxc --project "$PROJETO" stop db
lxc storage volume restore pool-final vol-db snap-volume
lxc --project "$PROJETO" start db
```

Backup portável: `lxc storage volume export pool-final vol-db ~/backup/vol-db.tar.gz`. Para derrubar somente instâncias, execute `ENV=prod ./scripts/destroy.sh`; acrescente `--volumes` para remover também o volume. O painel é iniciado com `./scripts/monitor.sh`.

## Evidências para a entrega

Guarde em `docs/evidencias/` as saídas de `lxc version`, redes, volumes, portas externas, teste DEV x PROD antes/depois da ACL, certificados, snapshots/restore e painel de monitoramento. Não comite senhas, tokens, chaves ou backups.
