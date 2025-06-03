FROM python:3.9-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    curl \
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
RUN echo 'from fastapi import FastAPI, HTTPException\n\
from fastapi.middleware.cors import CORSMiddleware\n\
import time\n\
import requests\n\
import os\n\
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
# Service URLs\n\
SERVICES = {\n\
    "suma": os.getenv("SUMA_URL", "http://localhost:8001"),\n\
    "resta": os.getenv("RESTA_URL", "http://localhost:8002"),\n\
    "ecuacion": os.getenv("ECUACION_URL", "http://localhost:8003"),\n\
    "almacenar": os.getenv("ALMACENAR_URL", "http://localhost:8004")\n\
}\n\
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
    try:\n\
        # Check if proxy itself is running\n\
        proxy_status = {"status": "healthy", "timestamp": time.time()}\n\
        \n\
        # Check other services\n\
        services_status = {}\n\
        for service_name, url in SERVICES.items():\n\
            try:\n\
                response = requests.get(f"{url}/health", timeout=2)\n\
                services_status[service_name] = "healthy" if response.status_code == 200 else "unhealthy"\n\
            except:\n\
                services_status[service_name] = "unreachable"\n\
        \n\
        return {\n\
            "proxy": proxy_status,\n\
            "services": services_status,\n\
            "overall_status": "healthy" if all(status == "healthy" for status in services_status.values()) else "degraded"\n\
        }\n\
    except Exception as e:\n\
        raise HTTPException(status_code=500, detail=str(e))' > /app/proxy.py

# Create a single entry point script
RUN echo '#!/bin/bash\n\
\n\
# Function to check if a service is ready\n\
check_service() {\n\
    local port=$1\n\
    local max_attempts=30\n\
    local attempt=1\n\
    \n\
    while [ $attempt -le $max_attempts ]; do\n\
        if curl -s http://localhost:$port/health > /dev/null; then\n\
            echo "Service on port $port is ready"\n\
            return 0\n\
        fi\n\
        echo "Waiting for service on port $port... (attempt $attempt/$max_attempts)"\n\
        sleep 2\n\
        attempt=$((attempt + 1))\n\
    done\n\
    \n\
    echo "Service on port $port failed to start"\n\
    return 1\n\
}\n\
\n\
# Start the proxy first\n\
cd /app && python -m uvicorn proxy:app --host 0.0.0.0 --port 8000 &\n\
\n\
# Wait for the proxy to start\n\
check_service 8000 || exit 1\n\
\n\
# Start the other services\n\
cd /app && python -m uvicorn suma.app.main:app --host 0.0.0.0 --port 8001 &\n\
cd /app && python -m uvicorn resta.app.main:app --host 0.0.0.0 --port 8002 &\n\
cd /app && python -m uvicorn ecuacion.app.main:app --host 0.0.0.0 --port 8003 &\n\
cd /app && python -m uvicorn almacenar.app.main:app --host 0.0.0.0 --port 8004 &\n\
\n\
# Wait for all services to be ready\n\
check_service 8001 || exit 1\n\
check_service 8002 || exit 1\n\
check_service 8003 || exit 1\n\
check_service 8004 || exit 1\n\
\n\
echo "All services are up and running"\n\
\n\
# Keep the container running\n\
wait' > /app/start.sh && \
chmod +x /app/start.sh

# Expose all ports
EXPOSE 8000 8001 8002 8003 8004

# Start all services
CMD ["/app/start.sh"] 