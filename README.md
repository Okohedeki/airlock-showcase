# airlock-showcase

Open-source, runnable proof that **[airlock](https://github.com/Okohedeki/airlock)** does what it
claims: take an agent built in *any* framework and run it as a controlled HTTP service — the same
control surface on every harness.

Six self-contained examples (one folder per harness), each a real worker you can run, plus a
**containerized test grid** that verifies them against a real local model. No airlock source lives
in this repo — airlock is installed as a dependency.

| Folder | Harness | Mode | What it shows |
|---|---|---|---|
| [`langgraph/`](langgraph) | `langgraph` | OWN | airlock extracts a LangGraph agent's tools and drives the loop |
| [`smolagents/`](smolagents) | `smolagents` | OWN | a smolagents `CodeAgent` |
| [`crewai/`](crewai) | `crewai` | OWN | a CrewAI crew |
| [`openai-agents/`](openai-agents) | `openai-agents` | OWN | the OpenAI Agents SDK |
| [`claude/`](claude) | `claude` | OWN | the Claude Agent SDK — *no Anthropic key* (airlock drives its own model) |
| [`custom/`](custom) | `custom` | **Terminal** | a plain callable: observe-only, no mid-run control — the honest contrast |

Every OWN harness gets the **same controls**. Each example also demonstrates **skills on/off**: a
`calc` skill (enabled) and a `danger` skill (disabled → `403` *and* dropped from the agent's loop).

## Prerequisite — a real local model

The examples drive a real OpenAI-compatible, **tool-calling** model on the host at `:11434`, e.g.
with llama.cpp:

```bash
llama-server -m ./Qwen2.5-3B-Instruct-Q4_K_M.gguf --port 11434 --jinja
```

A **3B+** tool-calling model is recommended (a 1B flails at tool use). To point elsewhere, edit
`OPENAI_API_BASE` in `docker-compose.yml` and `models.default.endpoint` in each `worker.yaml`.

## Verify it works — one command

```bash
./verify.sh
```

Builds one container per harness, waits until each is healthy, runs the grid, and tears down.
Expected: a green row per harness.

The grid (`tests/test_showcase.py`) asserts:

- **Strict (deterministic):** `/healthz`, `/v1/manifest` harness, skills `200/403/404`, OpenAI
  response shape, streaming frames ending in `[DONE]`.
- **Tolerant (real model):** the agent calls the `multiply` tool and the answer contains `437`.
- **custom:** returns a result but runs **no** tools (terminal).

## Drive a single harness by hand

```bash
docker compose up -d --build langgraph
curl -s -o /dev/null -w '%{http_code}\n' -X POST localhost:3101/skills/calc   -d '{}'   # 200 (enabled)
curl -s -o /dev/null -w '%{http_code}\n' -X POST localhost:3101/skills/danger -d '{}'   # 403 (disabled)
curl -s localhost:3101/v1/chat/completions -H 'content-type: application/json' \
  -d '{"messages":[{"role":"user","content":"Use the multiply tool to compute 23 times 19."}]}'
```

## Which airlock version is tested

Each image installs airlock from the public repo. Pin a tag/branch/sha:

```bash
docker compose build --build-arg AIRLOCK_REF=<tag-or-branch-or-sha>
```

(Defaults to the branch carrying the current showcase fixes.)

## Layout

```
airlock-showcase/
├── langgraph/  smolagents/  crewai/  openai-agents/  claude/  custom/   <- the 6 harnesses
│     each: agent.py · worker.yaml · requirements.txt · README.md
├── Dockerfile.harness     # per-harness image: installs airlock + the framework
├── docker-compose.yml     # 6 harness services + the test grid
├── tests/                 # the containerized verification suite
└── verify.sh              # one-command build + verify + teardown
```
