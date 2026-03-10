# OpenClaw

Personal LLM build powered by [OpenClaw](https://openclaw.ai). Runs a self-hosted AI gateway with a browser-based Control UI, fully containerized with Docker.

> **Primary platform:** macOS. Windows and Linux notes are included where the steps differ.

---

## Requirements

Before you begin, make sure you have the following installed:

- **Docker Desktop** ([Download here](https://www.docker.com/products/docker-desktop/)). This includes both Docker and Docker Compose.
- **An API key** from your preferred LLM provider (e.g. [Anthropic](https://console.anthropic.com/), [OpenAI](https://platform.openai.com/))
- **Git** ([Download here](https://git-scm.com/downloads))

To verify Docker is installed, open a terminal and run:
```bash
docker --version
```
You should see a version number. If not, install Docker Desktop first.

> **Windows:** Use PowerShell or Windows Terminal. Docker Desktop requires WSL2; the installer will guide you through enabling it.
> **Linux:** Install [Docker Engine](https://docs.docker.com/engine/install/) and the Docker Compose plugin. Docker Desktop is optional.

---

## Setup

### 1. Clone the repo

**macOS / Linux:**
```bash
git clone https://github.com/your-username/OpenClaw.git
cd OpenClaw
```

**Windows (PowerShell):**
```powershell
git clone https://github.com/your-username/OpenClaw.git
cd OpenClaw
```

### 2. Build and start the container

```bash
docker compose up -d
```

This will build the Docker image (takes a few minutes the first time) and start the container in the background.

To check it started successfully:
```bash
docker compose logs
```

You should see a line like:
```
[gateway] listening on ws://0.0.0.0:18789
```

### 3. Open the Control UI

Open your browser and go to:
```
http://127.0.0.1:18789
```

### 4. Get your auth token

The gateway requires a token to connect. Retrieve it by running:

**macOS / Linux:**
```bash
docker compose exec openclaw cat /data/config/openclaw.json
```

**Windows (PowerShell):**
```powershell
docker compose exec openclaw cat /data/config/openclaw.json
```

Look for the `"token"` field in the output, e.g.:
```json
"token": "abc123yourtokenhere"
```

Open the Control UI with your token in the URL:
```
http://127.0.0.1:18789/?auth=abc123yourtokenhere
```

### 5. Approve the device pairing

The first time you connect, the UI will show a **pairing required** screen. Run these two commands in your terminal:

```bash
# List pending pairing requests and copy the ID shown
docker compose exec openclaw openclaw devices list

# Approve the request (replace <requestId> with the ID from above)
docker compose exec openclaw openclaw devices approve <requestId>
```

Go back to the browser; you should now be connected.

### 6. Add your API key

In the Control UI, go to **Settings** and add your LLM provider API key (e.g. your Anthropic or OpenAI key). This is required before you can chat.

---

## Useful Commands

**macOS / Linux:**
```bash
# View live logs
docker compose logs -f

# Check gateway status
docker compose exec openclaw openclaw gateway status

# Stop the container
docker compose down

# WARNING: deletes all data including machines, API keys, and token. Cannot be undone.
docker compose down && rm -rf ./data
```

**Windows (PowerShell):**
```powershell
# View live logs
docker compose logs -f

# Check gateway status
docker compose exec openclaw openclaw gateway status

# Stop the container
docker compose down

# WARNING: deletes all data including machines, API keys, and token. Cannot be undone.
docker compose down; Remove-Item -Recurse -Force .\data
```

---

## Configuration

State and config are persisted in the `./data` folder so your setup, including your auth token and API keys, survives container restarts and rebuilds. You will only need to pair your device once.

> **Security note:** The gateway port (18789) is bound to `127.0.0.1` only; it is accessible from your machine alone, not from other devices on your network or the internet. Each user who builds this gets their own unique auth token generated locally; no tokens are stored in this repo. The `dangerouslyAllowHostHeaderOriginFallback` flag is required to make the Control UI work inside Docker and is safe as long as the port is not publicly exposed.

Override data locations via environment variables in `docker-compose.yml`:

| Variable | Default |
|---|---|
| `OPENCLAW_STATE_DIR` | `/data/state` |
| `OPENCLAW_CONFIG_PATH` | `/data/config/openclaw.json` |
