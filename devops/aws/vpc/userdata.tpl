#!/bin/bash

# Update the package list and upgrade all packages
sudo apt-get update -y

# Install Python3, pip, and other necessary packages
sudo apt-get install -y python3-pip python3-venv mysql-client

# Create a directory for the Flask application
mkdir -p /home/ubuntu/flask
chmod 755 /home/ubuntu/flask
cd /home/ubuntu/flask

# Create a Python virtual environment
python3 -m venv venv
source venv/bin/activate

# Install necessary Python packages
pip install flask pymysql mysql-connector-python

# Deactivate the virtual environment after installing packages
deactivate

# Connect to the MySQL database and set up the schema
mysql -h ${rds_address} -u root -proot123456 <<EOF
CREATE DATABASE IF NOT EXISTS mydb;
USE mydb;
CREATE TABLE IF NOT EXISTS ip_addresses (id INT AUTO_INCREMENT PRIMARY KEY, ip_address VARCHAR(45));
EOF

# Create a basic Flask app
cat <<EOT > /home/ubuntu/flask/app.py
from flask import Flask, jsonify, request
import mysql.connector

app = Flask(__name__)

@app.route('/')
def hello():
    client_ip = request.remote_addr
    # Connect to the MySQL database
    connection = mysql.connector.connect(
        host="${rds_address}",
        user="root",
        password="root123456",
        database="mydb"
    )
    cursor = connection.cursor()
    cursor.execute("insert into ip_addresses (ip_address) values(%s)", (client_ip,))
    connection.commit()
    connection.close()
    return "Hello, this is a Flask app!"

@app.route('/data')
def get_data():
    # Connect to the MySQL database
    connection = mysql.connector.connect(
        host="${rds_address}",
        user="root",
        password="root123456",
        database="mydb"
    )
    cursor = connection.cursor()
    cursor.execute("SELECT * FROM ip_addresses;")
    data = cursor.fetchall()
    connection.close()

    # Return the data as JSON
    return jsonify(data)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
EOT

# Set permissions for the script
sudo chmod +x /home/ubuntu/flask/app.py

# Create a systemd service for Flask
cat <<EOF | sudo tee /etc/systemd/system/flaskapp.service
[Unit]
Description=Flask Application
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/flask
Environment="PATH=/home/ubuntu/flask/venv/bin"
ExecStart=/home/ubuntu/flask/venv/bin/python3 /home/ubuntu/flask/app.py

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd to register the new service
sudo systemctl daemon-reload

# Start the Flask application service
sudo systemctl start flaskapp

# Enable the service to start on boot
sudo systemctl enable flaskapp
