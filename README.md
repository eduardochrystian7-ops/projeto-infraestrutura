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
