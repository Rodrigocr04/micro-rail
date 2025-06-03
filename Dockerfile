FROM python:3.9-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

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
COPY suma/ ./suma/
COPY resta/ ./resta/
COPY ecuacion/ ./ecuacion/
COPY almacenar/ ./almacenar/
COPY mysql/ ./mysql/

# Create a single entry point script
RUN echo '#!/bin/bash\n\
uvicorn suma:app --host 0.0.0.0 --port 8001 &\n\
uvicorn resta:app --host 0.0.0.0 --port 8002 &\n\
uvicorn ecuacion:app --host 0.0.0.0 --port 8003 &\n\
uvicorn almacenar:app --host 0.0.0.0 --port 8004 &\n\
wait' > /app/start.sh && \
chmod +x /app/start.sh

# Expose all ports
EXPOSE 8001 8002 8003 8004

# Start all services
CMD ["/app/start.sh"] 