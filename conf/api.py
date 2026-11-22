import os
import psycopg2
from fastapi import FastAPI, HTTPException, Request

app = FastAPI(title="API de Tarefas")


def conectar():
    return psycopg2.connect(
        host=os.environ["DB_HOST"], dbname="tarefas",
        user="apiuser", password=os.environ["DB_PASS"]
    )


@app.get("/api/saude")
def saude():
    return {"status": "ok"}


@app.get("/api/tarefas")
def listar():
    with conectar() as con, con.cursor() as cur:
        cur.execute("SELECT id, titulo, feita FROM tarefas ORDER BY id")
        return [{"id": r[0], "titulo": r[1], "feita": r[2]} for r in cur.fetchall()]


@app.post("/api/tarefas", status_code=201)
async def criar(req: Request):
    dados = await req.json()
    titulo = str(dados.get("titulo", "")).strip()
    if not titulo:
        raise HTTPException(400, "titulo e obrigatorio")
    with conectar() as con, con.cursor() as cur:
        cur.execute("INSERT INTO tarefas (titulo) VALUES (%s) RETURNING id", (titulo,))
        return {"id": cur.fetchone()[0], "titulo": titulo, "feita": False}


@app.patch("/api/tarefas/{tarefa_id}")
async def atualizar(tarefa_id: int, req: Request):
    feita = bool((await req.json()).get("feita"))
    with conectar() as con, con.cursor() as cur:
        cur.execute("UPDATE tarefas SET feita=%s WHERE id=%s", (feita, tarefa_id))
        if cur.rowcount == 0:
            raise HTTPException(404, "tarefa nao encontrada")
    return {"id": tarefa_id, "feita": feita}


@app.delete("/api/tarefas/{tarefa_id}")
def apagar(tarefa_id: int):
    with conectar() as con, con.cursor() as cur:
        cur.execute("DELETE FROM tarefas WHERE id=%s", (tarefa_id,))
        if cur.rowcount == 0:
            raise HTTPException(404, "tarefa nao encontrada")
    return {"removida": tarefa_id}

