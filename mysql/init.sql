-- This script is used to initialize the MySQL database for the microservices.
-- It is executed when the MySQL container starts for the first time.

-- Create the database if it does not already exist
CREATE DATABASE IF NOT EXISTS resultados_db;

-- Create a user 'myuser' that can connect from any host ('%')
-- and set their password.
-- Note: Using '%' for host allows connections from anywhere, which might be acceptable
-- in a controlled environment like a Docker network, but for production,
-- consider restricting the host to specific IPs or container names.
CREATE USER 'myuser'@'%' IDENTIFIED BY 'mypassword123';

-- Grant all privileges on the 'resultados_db' database to the 'myuser'
GRANT ALL PRIVILEGES ON resultados_db.* TO 'myuser'@'%';

-- Apply the privilege changes
FLUSH PRIVILEGES;


-- Switch to the 'resultados_db' to create tables within it
USE resultados_db;

-- Create the 'resultados' table if it does not already exist
CREATE TABLE IF NOT EXISTS resultados (
    id INT AUTO_INCREMENT PRIMARY KEY, -- Unique identifier for each result
    a FLOAT NOT NULL, -- Stores the value of input 'a'
    b FLOAT NOT NULL, -- Stores the value of input 'b'
    c FLOAT NOT NULL, -- Stores the value of input 'c'
    d FLOAT NOT NULL, -- Stores the value of input 'd'
    resultado FLOAT NOT NULL, -- Stores the final calculated result
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Timestamp when the result was recorded
);