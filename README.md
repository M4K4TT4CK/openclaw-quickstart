# OpenClaw Quickstart

![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Windows%20%7C%20Linux-blue)
![Docker](https://img.shields.io/badge/docker-required-2496ED?logo=docker&logoColor=white)
![License](https://img.shields.io/github/license/M4K4TT4CK/openclaw-quickstart)

> Your own AI gateway, running on your own machine, with your own rules. No cloud accounts, no subscriptions, no "oops we read your data" fine print.
>
> If you can open a terminal and paste a command, you can do this. Seriously.

---

## So what is this, exactly?

[OpenClaw](https://openclaw.ai) is a self-hosted AI gateway. Think of it as the middleman between you and whatever AI provider you use (Anthropic, OpenAI, etc.), except this middleman lives on your computer and answers to you.

This repo wraps OpenClaw in Docker so you can fire it up on any machine without touching your system Python, Node, or any of the other stuff that usually breaks when you try to install things. Your settings, your auth token, and your agent workspace all live in a local `./data` folder that never gets committed to git.

**Your AI. Your machine. Your rules.**

---

## How it fits together

### System Layout

![System Architecture](./diagrams/architecture.png)

> Want to dig into the source? [architecture.puml](./diagrams/architecture.puml) can be viewed with the [PlantUML extension](https://marketplace.visualstudio.com/items?itemName=jebbs.plantuml) in VSCode.

### What happens when you send a message

![Request Sequence](./diagrams/sequence.png)

> Source: [sequence.puml](./diagrams/sequence.puml).

---

## Before you start

You need three things. That is it.

- **Docker Desktop** ([grab it here](https://www.docker.com/products/docker-desktop/)). This bundles everything Docker, including Compose. One install, done.
- **An API key** from whichever AI provider you prefer: [Anthropic](https://console.anthropic.com/) or [OpenAI](https://platform.openai.com/). You will add this through the UI later, not in any config file.
- **Git** ([grab it here](https://git-scm.com/downloads)) so you can clone this repo.

Quick sanity check. Open a terminal and run:
```bash
docker --version
```
If you see a version number, you are good. If not, install Docker Desktop first and come back.

> **Windows users:** Use PowerShell or Windows Terminal. Docker Desktop needs WSL2; the installer walks you through it.
> **Linux users:** Install [Docker Engine](https://docs.docker.com/engine/install/) and the [Compose plugin](https://docs.docker.com/compose/install/linux/). Docker Desktop is optional.

---

## Setup

Six steps. Most of them are just copy and paste.

### 1. Clone the repo

**macOS / Linux:**
```bash
git clone https://github.com/M4K4TT4CK/openclaw-quickstart.git
cd openclaw-quickstart
```

**Windows (PowerShell):**
```powershell
git clone https://github.com/M4K4TT4CK/openclaw-quickstart.git
cd openclaw-quickstart
```

### 2. Fire it up

```bash
docker compose up -d
```

This builds the Docker image and starts the container in the background. The first build takes a few minutes since it has to pull the base image and install dependencies. Perfect time for a coffee.

> **Heads up:** This uses `docker compose` (no hyphen), which is Docker Compose V2. It ships with Docker Desktop on macOS and Windows. Linux users, grab the [Compose plugin](https://docs.docker.com/compose/install/linux/) if you do not have it. Still on the old `docker-compose`? Time to [upgrade](https://docs.docker.com/compose/migrate/).

Once it is running, confirm it started cleanly:
```bash
docker compose logs
```

You want to see something like:
```
[gateway] listening on ws://0.0.0.0:18789
```

### 3. Open the Control UI

Pop open your browser and head to:
```
http://127.0.0.1:18789
```

You will hit a connection screen. That is normal. You need your token first.

### 4. Grab your auth token

The gateway generates a unique token the first time it runs. No two installs share a token, and it is never stored in this repo. To retrieve yours:

**macOS / Linux:**
```bash
docker compose exec openclaw cat /data/config/openclaw.json
```

**Windows (PowerShell):**
```powershell
docker compose exec openclaw cat /data/config/openclaw.json
```

Dig out the `"token"` field from the output:
```json
"token": "abc123yourtokenhere"
```

Now load the Control UI with your token in the URL:
```
http://127.0.0.1:18789/?auth=abc123yourtokenhere
```

### 5. Approve the device pairing

First time through, the UI shows a **pairing required** screen. This is intentional. It means nothing can connect to your gateway without your explicit approval, not even your own browser until you say so.

Run these from your terminal (same on macOS, Windows, and Linux since they run inside the container):

```bash
# See what is waiting for approval
docker compose exec openclaw openclaw devices list

# Approve it (swap <requestId> for the ID shown above)
docker compose exec openclaw openclaw devices approve <requestId>
```

Flip back to the browser. You should now be in.

### 6. Add your API key

In the Control UI, go to **Settings** and drop in your LLM provider API key (Anthropic or OpenAI). You cannot chat until this is done. Your key lives in `./data` on your machine and never touches git.

That is it. You are running a local AI gateway.

---

## Handy commands

**macOS / Linux:**
```bash
# Watch logs in real time
docker compose logs -f

# Check gateway status
docker compose exec openclaw openclaw gateway status

# Stop everything
docker compose down

# Nuclear option: wipes all data including your token, machines, and API keys. Cannot be undone.
docker compose down && rm -rf ./data
```

**Windows (PowerShell):**
```powershell
# Watch logs in real time
docker compose logs -f

# Check gateway status
docker compose exec openclaw openclaw gateway status

# Stop everything
docker compose down

# Nuclear option: wipes all data including your token, machines, and API keys. Cannot be undone.
docker compose down; Remove-Item -Recurse -Force .\data
```

---

## Where does everything live?

Everything that matters persists in `./data` on your machine. Container restarts, rebuilds, even pulling a new version, none of that touches your data. The only thing that wipes it is the nuclear command above.

```
./data/
  config/openclaw.json   your token, gateway settings, API key refs
  state/                 session history
  workspace/             agent files (AGENTS.md, SOUL.md, MEMORY.md...)
```

> **Security note:** Port 18789 is bound to `127.0.0.1` only. That means it is reachable from your machine and nowhere else. No other device on your network can hit it, and neither can the internet. The `dangerouslyAllowHostHeaderOriginFallback` flag sounds scary but is safe here since the port is never publicly exposed; it is required to make the Control UI work inside Docker.

Want to move the data somewhere else? Override the paths in `docker-compose.yml`:

| Variable | Default |
|---|---|
| `OPENCLAW_STATE_DIR` | `/data/state` |
| `OPENCLAW_CONFIG_PATH` | `/data/config/openclaw.json` |

---

## Building your first agent with ChatGPT

Once your gateway is running and you have an OpenAI API key in Settings, you are ready to build an agent.

### 1. Make sure your OpenAI key is set

In the Control UI, go to **Settings** and add your OpenAI API key if you have not already. Select **OpenAI** as your provider and pick a model, `gpt-4o` is a solid starting point.

### 2. Create a new agent

In the Control UI, hit **New Agent** (or open the Agents panel). Give it a name, something like `My First Agent`. This creates a workspace for it under `./data/workspace/`.

### 3. Give it a personality

The best way to shape how your agent behaves is through a `SOUL.md` file. Think of it as a short brief you write for your agent: what it is for, how it should talk, what it should and should not do.

You can edit it directly in the Control UI, or open it in your editor at:
```
./data/workspace/SOUL.md
```

Example to get you started:
```markdown
You are a helpful assistant called Max.
You are concise, friendly, and never condescending.
When you do not know something, you say so instead of guessing.
```

### 4. Start chatting

That is genuinely it. Go back to the main chat view, select your agent, and start talking to it. Changes to `SOUL.md` take effect on the next message, so you can tune the personality without restarting anything.

### 5. Persist memory across conversations (optional)

OpenClaw agents can keep notes between sessions using a `MEMORY.md` file in their workspace. You can seed it manually or let the agent update it over time. It lives at:
```
./data/workspace/MEMORY.md
```

Anything you put in there gets loaded as context at the start of every conversation, so your agent can remember things like your name, preferences, or ongoing projects.
