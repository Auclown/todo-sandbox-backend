FROM python:3.14-slim

# 1. Environment Variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8080

# 2. Working directory
WORKDIR /app

# 3. Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# 4. Copy requirements first to leverage Docker layer cache
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip "setuptools>=78.1.1" "msgpack>=1.2.1" && \
    pip install --no-cache-dir --upgrade -r requirements.txt gunicorn && \
    rm -rf /usr/local/lib/python*/ensurepip /root/.cache

# 5. Copy the source code
COPY . .

# 6. Run container process as a non-root user
RUN adduser --disabled-password --gecos "" appuser && chown -R appuser:appuser /app
USER appuser

# 7. Expose port and start the server
EXPOSE 8080
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "2", "--threads", "8", "server.config.wsgi:application"]