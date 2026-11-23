# Projeto Final · Cloud Computing · Nuvem privada com LXD

**Instituição:** UNINASSAU · **Curso:** Sistemas da informação e Engenharia da computação
**Disciplina:** Cloud Computing
**Equipe:** 6 · **Projeto LXD:** `final-equipe6`
**Serviço implantado:** Trilha B · API de tarefas com FastAPI e PostgreSQL

## Integrantes

- Chrystian Eduardo Santos  Sousa / 01862423
- Heytor Farias Fernando da Silva / 01857126
- Isabelle Amorim Rodrigues / 01796342
- Jair Liberato da Silva Filho / 01864955
- Marcelo Nascimento silva / 01865122 
- Rodrigo Lucas Ferreira / 01811731

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


# Parte 3 · Acesso, TLS, automação, monitoramento e reprodução

## Pré-requisitos
- VM Ubuntu com LXD configurado, 4 GB livres e acesso à Internet
- Usuário com permissão para executar `lxc`
- Uma senha de banco segura. Ela é fornecida em execução, nunca gravada no Git

## Como reproduzir em uma VM nova

Substitua o `final-equipe6` apenas se o número da equipe mudar.

```bash
cd projeto-infraestrutura
chmod +x scripts/*.sh
export PROJETO=final-equipe6
DB_PASS='uma-senha-segura' ENV=prod ./scripts/deploy.sh
DB_PASS='uma-senha-segura' ENV=dev  ./scripts/deploy.sh
```

PROD publica HTTP em `http://<IP-DA-VM>:8081` e DEV em `http://<IP-DA-VM>:8082`. Troque `<IP-DA-VM>` pelo endereço real da VM (descubra com `ip -br addr`).

## Automação
- `scripts/deploy.sh` (`ENV=prod` ou `ENV=dev`) reconstrói o ambiente
- `scripts/destroy.sh` derruba as instâncias (use `--volumes` para apagar também os volumes)
- Teste de reprodutibilidade: <!-- TODO: destroy --volumes, deploy prod, deploy dev -->

## TLS

```bash
./scripts/gerar-tls.sh <IP-DA-VM>
ENV=prod ./scripts/habilitar-tls.sh
```

Importe `conf/tls/ca.crt` no navegador e abra `https://<IP-DA-VM>:8444`. Os arquivos privados são ignorados pelo Git.

## Acesso e perfis de usuário
- Admin (`admin-equipe6`): todos os projetos
- Operador (`operador-equipe6`): restrito ao projeto `final-equipe6`
- Teste do operador: <!-- TODO: projeto próprio funciona, `default` negado -->

## Monitoramento
- `scripts/monitor.sh`
- Prova dos limites do perfil (nproc, free -m, carga com `yes`): <!-- TODO -->

## Limitações e melhorias
<!-- TODO: alta disponibilidade, cluster, segredos, monitoramento avançado -->



