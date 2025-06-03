FROM python:3.9-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create Python package structure
RUN mkdir -p suma/app resta/app ecuacion/app almacenar/app

# Copy requirements files
COPY suma/requirements.txt ./suma/
COPY resta/requirements.txt ./resta/
COPY ecuacion/requirements.txt ./ecuacion/
COPY almacenar/requirements.txt ./almacenar/

# Install Python dependencies
RUN pip install --no-cache-dir \
    -r suma/requirements.txt \
    -r resta/requirements.txt \
    -r ecuacion/requirements.txt \
    -r almacenar/requirements.txt

# Copy application code
COPY suma/app/ ./suma/app/
COPY resta/app/ ./resta/app/
COPY ecuacion/app/ ./ecuacion/app/
COPY almacenar/app/ ./almacenar/app/
COPY mysql/ ./mysql/

# Create __init__.py files
RUN touch suma/__init__.py suma/app/__init__.py \
    resta/__init__.py resta/app/__init__.py \
    ecuacion/__init__.py ecuacion/app/__init__.py \
    almacenar/__init__.py almacenar/app/__init__.py

# Create a single entry point script
RUN echo '#!/bin/bash\n\
cd /app && uvicorn suma.app.main:app --host 0.0.0.0 --port 8001 &\n\
cd /app && uvicorn resta.app.main:app --host 0.0.0.0 --port 8002 &\n\
cd /app && uvicorn ecuacion.app.main:app --host 0.0.0.0 --port 8003 &\n\
cd /app && uvicorn almacenar.app.main:app --host 0.0.0.0 --port 8004 &\n\
wait' > /app/start.sh && \
chmod +x /app/start.sh

# Expose all ports
EXPOSE 8001 8002 8003 8004

# Start all services
CMD ["/app/start.sh"] 