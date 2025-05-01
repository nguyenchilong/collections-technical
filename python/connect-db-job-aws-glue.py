import socket
host = "host_to_connect_to_db"
port = 5432

def check_port(host, port):
    try:
        with socket.create_connection((host, port), timeout=30):
            print(f"✅ Connection successful to {host}:{port}")
    except Exception as e:
        print(f"❌ Connection failed to {host}:{port} - {e}")

# Run the connectivity test
check_port(host, port)
