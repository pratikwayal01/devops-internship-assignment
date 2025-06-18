# Use slim Python image
FROM python:3.12-slim AS base

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Create working directories with proper permissions
RUN mkdir -p /app /home/appuser/.cache /app/.uv-cache \
    && chown -R appuser:appuser /app /home/appuser

# Set working directory
WORKDIR /app

# Switch to non-root user
USER appuser

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV UV_CACHE_DIR=/app/.uv-cache

# Copy lock files
COPY --chown=appuser:appuser pyproject.toml uv.lock .python-version ./

# Rebuild the venv in runtime stage (under non-root user)
RUN uv venv && uv sync --frozen

# Copy application code
COPY --chown=appuser:appuser server.py ./

# Expose port
EXPOSE 8000

# Start the FastAPI app
CMD ["uv", "run", "fastapi", "run", "server.py", "--host", "0.0.0.0", "--port", "8000"]
