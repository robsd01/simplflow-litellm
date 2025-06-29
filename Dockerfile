FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

# DEBUG: confirm config is there
RUN cat litellm_config.yaml

# ✅ Clear old entrypoints
ENTRYPOINT []

# ✅ Start LiteLLM proxy server
CMD ["litellm", "--proxy-server", "--port", "4000"]
