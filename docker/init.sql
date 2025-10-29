CREATE DATABASE IF NOT EXISTS tourismdb;
USE tourismdb;

CREATE TABLE IF NOT EXISTS hebergements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(255),
    adresse VARCHAR(255),
    commune VARCHAR(255),
    code_postal VARCHAR(20),
    accessibilite VARCHAR(10),
    latitude DOUBLE,
    longitude DOUBLE,
    source JSON
);

CREATE USER IF NOT EXISTS 'appuser'@'%' IDENTIFIED BY 'apppassword';
GRANT ALL PRIVILEGES ON tourismdb.* TO 'appuser'@'%';
FLUSH PRIVILEGES;