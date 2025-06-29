# Use a Python base image. 'slim-buster' is good for smaller image sizes.
FROM python:3.10-slim-buster

# Set the working directory inside the container
WORKDIR /app

# Copy your LiteLLM configuration file into the container's working directory.
# Ensure this file is in the same directory as your Dockerfile.
COPY litellm_config.yaml .

# Install LiteLLM with its proxy server dependencies.
# The `[proxy]` extra ensures all necessary components for the proxy server are included.
# `--no-cache-dir` helps reduce the image size by not storing build cache.
RUN pip install litellm[proxy] --no-cache-dir

# Expose the port that LiteLLM will listen on.
# This makes it clear that the container expects traffic on this port.
EXPOSE 4000

# Set the ENTRYPOINT to the 'litellm' executable.
# This ensures that 'litellm' is always the first process run when the container starts.
# It overrides any default entrypoints from the base image or installed packages.
ENTRYPOINT ["litellm"]

# Set the default CMD arguments for the ENTRYPOINT.
# These arguments (`--proxy-server --port 4000`) will be passed to the 'litellm' ENTRYPOINT.
# If you run the container with additional arguments (e.g., `docker run my_image --help`),
# those arguments will override this default CMD.
CMD ["--proxy-server", "--port", "4000"]

# Ensure your Railway environment variables are set:
# OPENAI_API_KEY (and other provider keys)
# LITELLM_MASTER_KEY
# LITELLM_CONFIG_PATH=/app/litellm_config.yaml (or just litellm_config.yaml if in WORKDIR)
# LITELLM_PROXY_SERVER=true
