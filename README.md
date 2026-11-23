# Projeto Final · Cloud Computing · Nuvem privada com LXD

**Instituição:** UNINASSAU · **Curso:** Análise e Desenvolvimento de Sistemas
**Disciplina:** Cloud Computing
**Equipe:** 6 · **Projeto LXD:** `final-equipe6`
**Serviço implantado:** Trilha B · API de tarefas com FastAPI e PostgreSQL

## Integrantes

- Chrystian Eduardo
- Heitor Farias
- Isabelle Amorim
- Jair Filho
- Marcelo Nascimento
- Rodrigo Lucas

## Visão geral

Implementação da **trilha B** do roteiro: uma API de tarefas com FastAPI e PostgreSQL, publicada sobre uma nuvem privada LXD com redes isoladas (PROD e DEV), storage persistente, TLS, snapshots, automação e monitoramento. A arquitetura completa está em [docs/arquitetura.md](docs/arquitetura.md).

## Documentação

| Parte | Conteúdo | Arquivo |
|---|---|---|
| 1 | Arquitetura, decisões de projeto, rede e isolamento | [docs/readme/01-arquitetura-rede.md](docs/readme/01-arquitetura-rede.md) |
| 2 | Serviço, storage, persistência, snapshots e backup | [docs/readme/02-servico-storage-backup.md](docs/readme/02-servico-storage-backup.md) |
| 3 | Acesso, TLS, automação, monitoramento e reprodução | [docs/readme/03-acesso-automacao-monitoramento.md](docs/readme/03-acesso-automacao-monitoramento.md) |

## Estrutura do repositório

```
README.md
scripts/    deploy.sh, destroy.sh, monitor.sh, gerar-tls.sh, habilitar-tls.sh
profiles/   perfil-base, perfil-proxy, perfil-app, perfil-db (.yaml)
conf/       nginx e scripts de instalação (conf/tls fica fora do Git)
docs/       arquitetura.md, readme/ (partes deste README) e evidencias/
```
# Parte 2 · Arquitetura, decisões de projeto, rede e isolamento

## Arquitetura


```
Notebook --> VM cloud-lab (host LXD) <IP-DA-VM>
              | 8081 (http) e 8444 (https)   [dispositivo proxy do LXD]
              v
 net-prod 10.10.10.0/24:  proxy(.10) -> app(.11) -> db(.12)
 net-dev  10.10.20.0/24:  dev-proxy(.10) dev-app(.11) dev-db(.12)
 Storage: pool-final (dir) -> vol-db (PROD) e dev-vol-db (DEV)
```

- **proxy:** nginx com a página estática e proxy reverso da API
- **app:** API FastAPI (porta 8000, interna)
- **db:** PostgreSQL (porta 5432, interna)

## Decisões de projeto
- Container ou VM leve em cada camada, e por quê: <!-- TODO -->
- Por que `dir` no pool: <!-- TODO -->
- Por que duas redes (PROD e DEV): <!-- TODO -->

## Preparação do ambiente
- Projeto LXD: `final-equipe6`
- Teste de VM leve (KVM): <!-- TODO: resultado e kernel do host x da VM -->

## Redes, perfis e padrão de criação
- Redes `net-prod` (10.10.10.0/24) e `net-dev` (10.10.20.0/24), com NAT
- Perfis: `perfil-base`, `perfil-proxy`, `perfil-app`, `perfil-db`
- Padrão de criação de instância: <!-- TODO: as 5 linhas -->

## Isolamento e exposição
- Só o proxy é publicado (8081 e 8444); o banco não é acessível de fora: <!-- TODO: saída do Test-NetConnection -->
- DEV x PROD antes das ACLs: <!-- ALCANCOU -->
- DEV x PROD depois das ACLs: <!-- BLOQUEADO -->
- Bloqueio explícito do tráfego entre os ambientes: <!-- TODO: colar os comandos do README antigo -->

# Parte 2 · Serviço, storage, persistência, snapshots e backup

## Serviço implantado (trilha B)
- **proxy** (nginx): página estática e proxy reverso para `/api/`
- **app** (FastAPI): API de tarefas, porta 8000
- **db** (PostgreSQL): banco `tarefas`, usuário `apiuser`
- Endpoints: `GET /api/saude`, `GET/POST /api/tarefas`, `PATCH/DELETE /api/tarefas/{id}`
- Publicação: PROD em `http://<IP-DA-VM>:8081` e DEV em `http://<IP-DA-VM>:8082`
- Scripts em `conf/`: <!-- TODO: config-postgres.sh, api.py, api.service, instala-api.sh, index.html, nginx -->

## Storage
- Pool `pool-final` (dir)
- Os dados do PostgreSQL ficam em `pool-final/vol-db` (PROD) e `dev-vol-db` (DEV), montados em `/dados`

## Prova de persistência
<!-- TODO: antes.json e depois.json, `lxc list` nos dois momentos, mensagem DADOS PRESERVADOS -->

## Snapshots e backup
- Snapshot de instância e de volume: <!-- TODO -->
- Desastre simulado (apagar tarefas pela API): <!-- TODO -->
- Restauração (com o `db` parado): <!-- TODO -->
- Export e import: <!-- TODO -->

### Procedimento de restauração (5 linhas)
1. <!-- TODO -->
2.
3.
4.
5.
