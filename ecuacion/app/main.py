# main.py for the Ecuacion microservice
# This service orchestrates calls to the suma and resta services,
# performs a calculation, and stores the result in a MySQL database.

# Import necessary libraries
from fastapi import FastAPI, HTTPException # FastAPI framework and exception handling
from pydantic import BaseModel # For data validation
import requests # To make HTTP requests to other services
import mysql.connector # To connect to the MySQL database
import os # To access environment variables

# Create a FastAPI application instance
app = FastAPI()

# Define the request body structure using Pydantic BaseModel for the /resolver endpoint
class Input(BaseModel):
    a: float # First input for suma
    b: float # Second input for suma
    c: float # First input for resta
    d: float # Second input for resta

# Function to establish a database connection using environment variables
# This allows flexible configuration in different environments (local, Railway, etc.)
def get_db_connection():
   return mysql.connector.connect(
        host=os.getenv("MYSQL_HOST", "mysql"), # Database host, default to 'mysql'
        user=os.getenv("MYSQL_USER", "myuser"), # Database user, default to 'myuser'
        password=os.getenv("MYSQL_PASSWORD", "mypassword123"), # Database password, default
        database=os.getenv("MYSQL_DATABASE", "resultados_db") # Database name, default
    )

# Define the POST endpoint for resolving the equation (suma result * resta result)
# The path is '/resolver'
@app.post("/resolver")
# The function `resolver` handles requests to this endpoint
# It receives the input data validated by the Input model
def resolver(valores: Input):
    print("Entra a resolver") # Log entry point
    try:
        # Call the suma service
        suma_resp = requests.post("http://suma:8000/sumar", json={"a": valores.a, "b": valores.b}, timeout=5)
        suma_resp.raise_for_status() # Raise HTTPError for bad responses (4xx or 5xx)
        # Call the resta service
        resta_resp = requests.post("http://resta:8000/restar", json={"a": valores.c, "b": valores.d}, timeout=5)
        resta_resp.raise_for_status() # Raise HTTPError for bad responses (4xx or 5xx)
    except requests.RequestException as e:
        # Handle errors during communication with suma or resta services
        raise HTTPException(status_code=502, detail=f"Error al comunicarse con suma/resta: {e}")

    print("Entra a segundo try") # Log point after service calls
    try:
        # Extract results from JSON responses
        suma = suma_resp.json().get("resultado")
        resta = resta_resp.json().get("resultado")
        # Check if results were successfully extracted
        if suma is None or resta is None:
            raise HTTPException(status_code=502, detail="Respuesta inválida de suma/resta")
    except Exception:
        # Handle errors during JSON processing
        raise HTTPException(status_code=502, detail="Error procesando la respuesta JSON de suma/resta")

    # Perform the final calculation
    resultado = suma * resta
    print ("resultado -->", resultado) # Log the final result

    # Database interaction
    db = None
    cursor = None
    try:
        db = get_db_connection() # Get database connection
        cursor = db.cursor() # Create a cursor object

        # Prepare the SQL query to insert the result
        query = "INSERT INTO resultados (operacion, resultado) VALUES (%s, %s)"
        # Prepare the values to be inserted
        # Note: The original code intended to store a, b, c, d, but the table only has operacion and resultado.
        # Assuming 'operacion' will store a string representation or the calculation type.
        # Let's store the result of the operation.
        # If you need to store a, b, c, d, the database schema or insert query needs adjustment.
        valores_to_insert = (f"({valores.a} + {valores.b}) * ({valores.c} - {valores.d})", resultado)
        
        # Execute the insert query
        cursor.execute(query, valores_to_insert)
        db.commit() # Commit the transaction

    except mysql.connector.Error as err:
        # Handle database errors
        raise HTTPException(status_code=500, detail=f"Error en base de datos: {err}")
    finally:
        # Ensure cursor and database connection are closed
        if cursor:
            cursor.close()
        if db and db.is_connected():
            db.close()

    # Return the final result
    return {"resultado": resultado}

# Define the GET endpoint for retrieving the history of results
# The path is '/historial'
@app.get("/historial")
def historial():
    db = None
    cursor = None
    try:
        db = get_db_connection() # Get database connection
        cursor = db.cursor(dictionary=True) # Create a cursor, fetch rows as dictionaries
        
        # Prepare the SQL query to select the last 10 results
        query = "SELECT * FROM resultados ORDER BY id DESC LIMIT 10"
        # Execute the select query
        cursor.execute(query)
        
        # Fetch all the results
        resultados = cursor.fetchall()
        
        # Return the history as a JSON object
        return {"historial": resultados}
    except Exception as e:
        # Handle errors during database interaction
        return {"error": f"Error al obtener el historial: {str(e)}"}
    finally:
        # Ensure cursor and database connection are closed
        if cursor:
            cursor.close()
        if db and db.is_connected():
            db.close()
