# main.py for the Resta microservice
# Uses FastAPI to provide an endpoint for subtracting two numbers.

# Import necessary libraries
from fastapi import FastAPI # FastAPI framework
from pydantic import BaseModel # For data validation

# Create a FastAPI application instance
app = FastAPI()

# Define the request body structure using Pydantic BaseModel
# This defines the expected input when performing a subtraction operation.
class Input(BaseModel):
    a: float # First number (float)
    b: float # Second number (float)

# Define the POST endpoint for subtracting numbers
# The path is '/restar'
@app.post("/restar")
# The function `restar` handles requests to this endpoint
# It receives the input data validated by the Input model
def restar(valores: Input):
    # Perform the subtraction operation
    resultado = valores.a - valores.b
    # Return the result as a JSON object
    return {"resultado": resultado}
