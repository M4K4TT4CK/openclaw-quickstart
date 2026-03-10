# OpenClaw

Personal LLM build powered by [OpenClaw](https://openclaw.ai). Runs a self-hosted AI gateway with a browser-based Control UI.

## Requirements

- Docker and Docker Compose
- An API key for your preferred LLM provider (e.g. Anthropic, OpenAI)

## Quick Start

```bash
# 1. Clone the repo
git clone https://github.com/your-username/OpenClaw.git
cd OpenClaw

# 2. Build and start the container
docker compose up -d

# 3. Open the Control UI to complete setup
open http://127.0.0.1:18789
```

> The gateway starts in `--allow-unconfigured` mode so the container runs before any config is set. Complete setup — including adding your API key — via the Control UI at the URL above.

> Each user brings their own API key. No secrets are stored in this repo.

## Useful Commands

```bash
# View logs
docker compose logs -f

# Check gateway status
docker compose exec openclaw openclaw gateway status

# Stop the container
docker compose down
```

## Configuration

State and config are persisted in a Docker volume (`openclaw-data`) so your setup survives container restarts and rebuilds.

Override locations via environment variables in `docker-compose.yml`:

| Variable | Default |
|---|---|
| `OPENCLAW_STATE_DIR` | `/data/state` |
| `OPENCLAW_CONFIG_PATH` | `/data/config/openclaw.json` |
