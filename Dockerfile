# Base image for building
ARG LITELLM_BUILD_IMAGE=cgr.dev/chainguard/python:latest-dev
ARG LITELLM_RUNTIME_IMAGE=cgr.dev/chainguard/python:latest-dev

FROM $LITELLM_BUILD_IMAGE AS builder

WORKDIR /app
USER root

RUN apk add --no-cache gcc python3-dev openssl openssl-dev
RUN pip install --upgrade pip && pip install build

COPY . .

RUN chmod +x docker/build_admin_ui.sh && ./docker/build_admin_ui.sh
RUN rm -rf dist/* && python -m build
RUN pip install dist/*.whl
RUN pip wheel --no-cache-dir --wheel-dir=/wheels/ -r requirements.txt
RUN pip uninstall jwt -y && pip uninstall PyJWT -y && pip install PyJWT==2.9.0 --no-cache-dir

FROM $LITELLM_RUNTIME_IMAGE AS runtime

USER root
WORKDIR /app

RUN apk add --no-cache openssl tzdata
COPY . .
COPY --from=builder /app/dist/*.whl .
COPY --from=builder /wheels/ /wheels/

RUN pip install *.whl /wheels/* --no-index --find-links=/wheels/ && rm -f *.whl && rm -rf /wheels

RUN prisma generate

# ✅ DEBUG: Show your config file in logs (optional)
RUN cat /app/litellm_config.yaml

# ✅ CRUCIAL: Clear old ENTRYPOINT to avoid Uvicorn!
ENTRYPOINT []

# ✅ Run LiteLLM Proxy Mode
CMD ["litellm", "--proxy-server", "--port", "4000"]
