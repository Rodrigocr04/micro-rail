# main.py for the Suma microservice
# Uses FastAPI to provide an endpoint for adding two numbers.

# Import necessary libraries
from fastapi import FastAPI # FastAPI framework
from pydantic import BaseModel # For data validation

# Create a FastAPI application instance
app = FastAPI()

# Define the request body structure using Pydantic BaseModel
# This defines the expected input when performing a sum operation.
class Input(BaseModel):
    a: float # First number (float)
    b: float # Second number (float)

# Define the POST endpoint for summing numbers
# The path is '/sumar'
@app.post("/sumar")
# The function `sumar` handles requests to this endpoint
# It receives the input data validated by the Input model
def sumar(valores: Input):
    # Perform the sum operation
    resultado = valores.a + valores.b
    # Return the result as a JSON object
    return {"resultado": resultado}
