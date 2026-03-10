FROM node:22-slim

# Install git (required by OpenClaw) and clean up
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Install OpenClaw via npm (bypasses the interactive install script)
RUN npm install -g openclaw

# Set default state/config locations inside the container
ENV OPENCLAW_STATE_DIR=/data/state
ENV OPENCLAW_CONFIG_PATH=/data/config/openclaw.json

# Create data directories
RUN mkdir -p /data/state /data/config

# Expose the gateway port
EXPOSE 18789

# Persist state and config outside the container
VOLUME ["/data"]

CMD ["openclaw", "gateway", "run", "--allow-unconfigured"]
