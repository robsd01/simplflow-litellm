FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN cat /app/litellm_config.yaml

ENTRYPOINT []

CMD ["litellm", "--proxy-server", "--port", "4000"]
