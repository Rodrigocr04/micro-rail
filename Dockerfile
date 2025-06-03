FROM docker/compose:1.29.2

WORKDIR /app

# Copy only the necessary files first
COPY docker-compose.yaml .

# Create directories
RUN mkdir -p suma resta ecuacion almacenar mysql

# Copy service files
COPY suma/ ./suma/
COPY resta/ ./resta/
COPY ecuacion/ ./ecuacion/
COPY almacenar/ ./almacenar/
COPY mysql/ ./mysql/

# Set environment variables
ENV DOCKER_COMPOSE_VERSION=1.29.2

# Verify the installation
RUN docker-compose --version

# Start the services
CMD ["docker-compose", "up", "--build"] 