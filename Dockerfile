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
    -r almacenar/requirements.txt \
    fastapi \
    uvicorn \
    python-multipart

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

# Add the current directory to PYTHONPATH
ENV PYTHONPATH=/app

# Create a proxy service that will handle the main port
RUN echo 'from fastapi import FastAPI\n\
from fastapi.middleware.cors import CORSMiddleware\n\
import time\n\
\n\
app = FastAPI()\n\
\n\
app.add_middleware(\n\
    CORSMiddleware,\n\
    allow_origins=["*"],\n\
    allow_credentials=True,\n\
    allow_methods=["*"],\n\
    allow_headers=["*"],\n\
)\n\
\n\
@app.on_event("startup")\n\
async def startup_event():\n\
    # Give other services time to start\n\
    time.sleep(5)\n\
\n\
@app.get("/")\n\
async def root():\n\
    return {"message": "API Gateway is running"}\n\
\n\
@app.get("/health")\n\
async def health():\n\
    return {"status": "healthy", "timestamp": time.time()}' > /app/proxy.py

# Create a single entry point script
RUN echo '#!/bin/bash\n\
\n\
# Start the proxy first\n\
cd /app && python -m uvicorn proxy:app --host 0.0.0.0 --port 8000 &\n\
\n\
# Wait for the proxy to start\n\
sleep 5\n\
\n\
# Start the other services\n\
cd /app && python -m uvicorn suma.app.main:app --host 0.0.0.0 --port 8001 &\n\
cd /app && python -m uvicorn resta.app.main:app --host 0.0.0.0 --port 8002 &\n\
cd /app && python -m uvicorn ecuacion.app.main:app --host 0.0.0.0 --port 8003 &\n\
cd /app && python -m uvicorn almacenar.app.main:app --host 0.0.0.0 --port 8004 &\n\
\n\
# Keep the container running\n\
wait' > /app/start.sh && \
chmod +x /app/start.sh

# Expose all ports
EXPOSE 8000 8001 8002 8003 8004

# Start all services
CMD ["/app/start.sh"] 