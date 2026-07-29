# Use an official lightweight Python image
FROM python:3.11-slim

# Prevent Python from writing .pyc files and buffer stdout/stderr
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Install build deps (if any) then clean apt lists to keep image small
RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential && \
    rm -rf /var/lib/apt/lists/*

# Copy the project
COPY . /app

# Install python deps: prefer requirements.txt, otherwise try to install package if available
RUN if [ -f requirements.txt ]; then \
      pip install --no-cache-dir -r requirements.txt; \
    elif [ -f pyproject.toml ]; then \
      pip install --no-cache-dir .; \
    fi

# Create a non-root user and give ownership of the app directory
RUN adduser --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

EXPOSE 8000
ENV PORT=8000

# Default command: adjust the WSGI/ASGI entrypoint as needed for your project
# For example, change `app:app` to `myproject.main:app` or run a different server if needed.
CMD ["uvicorn", "app:app", "--bind", "0.0.0.0", "--port", PORT]
