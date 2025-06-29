FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Optional: show your config for debug
RUN cat /app/litellm_config.yaml

# ✅ Prevent old entrypoints
ENTRYPOINT []

# ✅ Start LiteLLM Proxy Server directly
CMD ["litellm", "--proxy-server", "--port", "4000"]
