# Microservicios en Railway

Este proyecto consiste en una aplicación de microservicios desplegada en Railway.

## Servicios

- **suma**: Servicio para realizar operaciones de suma
- **resta**: Servicio para realizar operaciones de resta
- **ecuacion**: Servicio para resolver ecuaciones
- **almacenar**: Servicio para almacenar resultados en MySQL
- **mysql**: Base de datos MySQL

## Despliegue de Aplicación en Railway

## Pasos para Desplegar la Aplicación en la Nube

1. **Preparación del Código**
   - Asegúrate de que todos los archivos estén en el repositorio Git
   - Verifica que el `Dockerfile` y `railway.toml` estén correctamente configurados
   - Confirma que todos los servicios tengan sus endpoints de salud implementados

2. **Configuración en Railway**
   - Ve a [Railway.app](https://railway.app/)
   - Inicia sesión con tu cuenta de GitHub
   - Crea un nuevo proyecto
   - Selecciona "Deploy from GitHub repo"
   - Conecta tu repositorio de GitHub

3. **Configuración de Variables de Entorno**
   En Railway, configura las siguientes variables de entorno:
   ```
   MYSQL_HOST=tu-host-mysql
   MYSQL_USER=tu-usuario
   MYSQL_PASSWORD=tu-contraseña
   MYSQL_DATABASE=tu-base-de-datos
   PORT=8000
   SUMA_URL=http://localhost:8001
   RESTA_URL=http://localhost:8002
   ECUACION_URL=http://localhost:8003
   ALMACENAR_URL=http://localhost:8004
   ```

4. **Configuración de la Base de Datos**
   - En Railway, agrega un servicio de MySQL
   - Railway te proporcionará automáticamente las credenciales
   - Actualiza las variables de entorno con las credenciales proporcionadas

5. **Despliegue**
   - Railway detectará automáticamente el `Dockerfile`
   - Iniciará el proceso de construcción de la imagen
   - Desplegará el contenedor
   - Configurará el health check

6. **Verificación del Despliegue**
   - Monitorea los logs en Railway para verificar que:
     - Todos los servicios inicien correctamente
     - Los health checks pasen
     - No haya errores en la conexión a la base de datos
   - Verifica que la aplicación esté accesible en la URL proporcionada por Railway

7. **Pruebas Post-Despliegue**
   - Prueba el endpoint principal: `https://tu-app.railway.app/`
   - Verifica el health check: `https://tu-app.railway.app/health`
   - Prueba cada microservicio:
     - Suma: `https://tu-app.railway.app/suma`
     - Resta: `https://tu-app.railway.app/resta`
     - Ecuación: `https://tu-app.railway.app/ecuacion`
     - Almacenar: `https://tu-app.railway.app/almacenar`

8. **Monitoreo Continuo**
   - Configura alertas en Railway para:
     - Fallos en el health check
     - Errores en los servicios
     - Problemas de conexión con la base de datos
   - Monitorea el uso de recursos
   - Revisa los logs periódicamente

9. **Mantenimiento**
   - Realiza backups regulares de la base de datos
   - Monitorea el uso de recursos
   - Actualiza las dependencias cuando sea necesario
   - Revisa los logs para detectar problemas potenciales

10. **Escalabilidad**
    - Railway manejará automáticamente el escalado
    - Monitorea el rendimiento
    - Ajusta los recursos según sea necesario

## Características del Dashboard de Railway

Railway proporciona un dashboard donde puedes:
- Ver los logs en tiempo real
- Monitorear el rendimiento
- Configurar variables de entorno
- Gestionar la base de datos
- Ver el estado de los servicios

## Soporte

Si necesitas más detalles sobre algún paso específico o tienes problemas durante el despliegue, por favor crea un issue en el repositorio.

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