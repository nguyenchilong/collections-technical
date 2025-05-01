
import socket

# get private IP in Job of Glue
hostname = socket.gethostname()
private_ip = socket.gethostbyname(hostname)
print(f"Private IP of AWS Glue: {private_ip}")