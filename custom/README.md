# custom harness (Terminal)

Your own code as an airlock worker: a plain `run(messages) -> str` callable. airlock can only
**observe the final result** — there are no tools to extract and **no mid-run control**. This is
the honest contrast to the OWN harnesses (see airlock's CONTEXT.md: OWN / WRAP / Terminal).

To get the full control set on `custom`, implement airlock's `Planner` protocol or expose
extractable tools.

- `agent.py` — a `run(messages)` callable (here, a trivial calculator).
- `worker.yaml` — `harness: custom`, `entrypoint: agent:run`. No `models`, no `skills`.

## Run + drive

```bash
docker compose up -d --build custom
curl -s localhost:3106/v1/chat/completions -H 'content-type: application/json' \
  -d '{"messages":[{"role":"user","content":"compute 23 times 19"}],"include_steps":true}'
# -> returns "437", and steps contains NO tool_result (terminal: airlock ran no tools)
```
