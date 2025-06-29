# Base image for building
ARG LITELLM_BUILD_IMAGE=cgr.dev/chainguard/python:latest-dev

# Runtime image
ARG LITELLM_RUNTIME_IMAGE=cgr.dev/chainguard/python:latest-dev

# Builder stage
FROM $LITELLM_BUILD_IMAGE AS builder

WORKDIR /app
USER root

# Install build dependencies
RUN apk add --no-cache gcc python3-dev openssl openssl-dev

RUN pip install --upgrade pip && pip install build

# Copy the project into the container
COPY . .

# Build Admin UI
RUN chmod +x docker/build_admin_ui.sh && ./docker/build_admin_ui.sh

# Build the Python package
RUN rm -rf dist/* && python -m build

# Install the built wheel
RUN pip install dist/*.whl

# Preinstall dependencies as wheels
RUN pip wheel --no-cache-dir --wheel-dir=/wheels/ -r requirements.txt

# Ensure correct JWT library
RUN pip uninstall jwt -y && pip uninstall PyJWT -y && pip install PyJWT==2.9.0 --no-cache-dir

# Runtime stage
FROM $LITELLM_RUNTIME_IMAGE AS runtime

USER root
WORKDIR /app

# Install runtime system deps
RUN apk add --no-cache openssl tzdata

# Copy code and wheels from builder
COPY . .
COPY --from=builder /app/dist/*.whl .
COPY --from=builder /wheels/ /wheels/

# Install the built wheel and all dependencies
RUN pip install *.whl /wheels/* --no-index --find-links=/wheels/ && rm -f *.whl && rm -rf /wheels

# Generate Prisma client
RUN prisma generate

# Output config for debug (optional — safe to remove)
RUN cat /app/litellm_config.yaml

# Ensure old ENTRYPOINT is cleared
ENTRYPOINT []

# Start LiteLLM Proxy Server
CMD ["litellm", "--proxy-server", "--port", "4000"]
