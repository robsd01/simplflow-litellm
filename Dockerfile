# Use Python 3.11 slim image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy configuration file
COPY litellm_config.yaml .

# Set environment variables
ENV LITELLM_CONFIG_PATH=/app/litellm_config.yaml
ENV PORT=4000

# Expose port
EXPOSE 4000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:4000/health || exit 1

# Clear any inherited entrypoint and run LiteLLM proxy
ENTRYPOINT []
CMD ["litellm", "--config", "/app/litellm_config.yaml", "--port", "4000", "--host", "0.0.0.0"]
