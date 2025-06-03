FROM docker/compose:latest

WORKDIR /app

COPY docker-compose.yaml .
COPY suma ./suma
COPY resta ./resta
COPY ecuacion ./ecuacion
COPY almacenar ./almacenar
COPY mysql ./mysql

CMD ["docker-compose", "up"] 