# main.py for the Almacenar microservice
# Handles storing operation results in the MySQL database.

# Import necessary libraries
from fastapi import FastAPI, HTTPException # FastAPI framework and exception handling
from pydantic import BaseModel # For data validation
import mysql.connector # To connect to the MySQL database
import os # To access environment variables

# Create a FastAPI application instance
app = FastAPI()

# Define the request body structure using Pydantic BaseModel
# This defines the expected input when storing a result.
class ResultInput(BaseModel):
    operacion: str # Description of the operation (string)
    resultado: float # The result of the operation (float)

# Function to establish a database connection using environment variables
# This allows flexible configuration in different environments (local, Railway, etc.)
def get_db_connection():
    return mysql.connector.connect(
        host=os.getenv("MYSQL_HOST", "mysql"), # Database host, default to 'mysql'
        user=os.getenv("MYSQL_USER", "myuser"), # Database user, default to 'myuser'
        password=os.getenv("MYSQL_PASSWORD", "mypassword123"), # Database password, default
        database=os.getenv("MYSQL_DATABASE", "resultados_db") # Database name, default
    )

# Define the POST endpoint for storing results
# The path is '/almacenar'
@app.post("/almacenar")
# The function `store_result` handles requests to this endpoint
# It receives the input data validated by the ResultInput model
def store_result(data: ResultInput):
    db = None
    cursor = None
    try:
        db = get_db_connection() # Get database connection
        cursor = db.cursor() # Create a cursor object

        # Prepare the SQL query to insert the result
        query = "INSERT INTO resultados (operacion, resultado) VALUES (%s, %s)"
        # Prepare the values to be inserted
        values = (data.operacion, data.resultado)
        
        # Execute the insert query
        cursor.execute(query, values)
        db.commit() # Commit the transaction
        
        # Return a success message
        return {"message": "Resultado almacenado con éxito"}

    except mysql.connector.Error as err:
        # Handle database errors
        raise HTTPException(status_code=500, detail=f"Error en base de datos: {err}")
    finally:
        # Ensure cursor and database connection are closed
        if cursor:
            cursor.close()
        if db and db.is_connected():
            db.close()
