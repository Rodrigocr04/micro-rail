# Microservicios en Railway

Este proyecto consiste en una aplicación de microservicios desplegada en Railway.

## Servicios

- **suma**: Servicio para realizar operaciones de suma
- **resta**: Servicio para realizar operaciones de resta
- **ecuacion**: Servicio para resolver ecuaciones
- **almacenar**: Servicio para almacenar resultados en MySQL
- **mysql**: Base de datos MySQL

## Despliegue en Railway

1. **Crear una cuenta en Railway**
   - Visita [Railway.app](https://railway.app)
   - Regístrate con tu cuenta de GitHub

2. **Crear un nuevo proyecto**
   - Haz clic en "New Project"
   - Selecciona "Deploy from GitHub repo"
   - Selecciona este repositorio

3. **Configurar variables de entorno**
   En Railway, ve a la sección "Variables" y configura las siguientes variables:

   ```env
   # Database Configuration
   MYSQL_HOST=railway-mysql
   MYSQL_USER=railway
   MYSQL_PASSWORD=railway
   MYSQL_DATABASE=resultados_db
   MYSQL_PORT=3306

   # Service URLs
   SUMA_URL=http://suma:8000
   RESTA_URL=http://resta:8000
   ECUACION_URL=http://ecuacion:8000
   ALMACENAR_URL=http://almacenar:8000

   # Service Ports
   SUMA_PORT=8000
   RESTA_PORT=8000
   ECUACION_PORT=8000
   ALMACENAR_PORT=8000
   ```

4. **Desplegar la aplicación**
   - Railway detectará automáticamente el archivo `railway.toml`
   - Iniciará el despliegue de los servicios
   - Puedes monitorear el progreso en la sección "Deployments"

## Pruebas

Una vez desplegado, puedes probar los servicios usando las URLs proporcionadas por Railway:

- Suma: `POST /sumar`
  ```json
  {
    "a": 15,
    "b": 17
  }
  ```

- Resta: `POST /restar`
  ```json
  {
    "a": 15,
    "b": 17
  }
  ```

- Ecuación: `POST /ecuacion`
  ```json
  {
    "a": 15,
    "b": 17
  }
  ```

## Monitoreo

- Railway proporciona logs en tiempo real
- Puedes monitorear el uso de recursos
- Los healthchecks verifican el estado de los servicios

## Troubleshooting

Si encuentras problemas:

1. Verifica los logs en Railway
2. Asegúrate de que todas las variables de entorno estén configuradas
3. Verifica que los servicios estén corriendo
4. Comprueba la conectividad entre servicios 