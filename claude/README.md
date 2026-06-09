# Claude Agent SDK harness

Claude Agent SDK tools run as a controlled airlock worker — **no Anthropic key needed**, airlock drives its own model. airlock **extracts the agent's tools and drives the loop itself** (OWN control mode), so the
full control set applies — guards, approvals, routing, fallback, skills, traces.

- `agent.py` — `build_options()` returns the SDK tool list, exposing two tools: `multiply` and `danger`.
- `worker.yaml` — the manifest: model binding, **skills** (`calc`→multiply *enabled*,
  `danger`→danger *disabled*), controls (max_steps, budget), io, sqlite state.
- `requirements.txt` — the framework only (airlock comes from the image).

## Run (from the repo root)

```bash
docker compose up -d --build claude
curl -s localhost:3105/v1/manifest | python3 -m json.tool
```

## Skills on/off

```bash
curl -s -o /dev/null -w '%{http_code}\n' -X POST localhost:3105/skills/calc   -d '{}'   # 200  (enabled)
curl -s -o /dev/null -w '%{http_code}\n' -X POST localhost:3105/skills/danger -d '{}'   # 403  (disabled)
curl -s -o /dev/null -w '%{http_code}\n' -X POST localhost:3105/skills/nope   -d '{}'   # 404  (unknown)
```

Disabling `danger` also **drops it from the agent's loop**. Flip `enabled: true` in
`worker.yaml`, rebuild (`docker compose up -d --build claude`), and the same delete request runs.

## Drive the agent

```bash
curl -s localhost:3105/v1/chat/completions -H 'content-type: application/json' \
  -d '{"messages":[{"role":"user","content":"Use the multiply tool to compute 23 times 19."}]}'
```
