#!/bin/bash

# Create app directories
mkdir -p suma/app resta/app ecuacion/app almacenar/app

# Move and rename files
mv suma/suma.py suma/app/main.py
mv resta/resta.py resta/app/main.py
mv ecuacion/ecuacion.py ecuacion/app/main.py
mv almacenar/almacenar.py almacenar/app/main.py

# Create __init__.py files
touch suma/__init__.py suma/app/__init__.py
touch resta/__init__.py resta/app/__init__.py
touch ecuacion/__init__.py ecuacion/app/__init__.py
touch almacenar/__init__.py almacenar/app/__init__.py 