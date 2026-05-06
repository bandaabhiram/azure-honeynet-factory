"""
Safe Attacker Simulation — Controlled port scan against honeypot VM.
Used to validate Sentinel detection rules without real malicious activity.
"""
import socket
import sys


def gentle_port_scan(target_ip: str, ports: list):
    """Single SYN packet per port — gentle enough for testing."""
    for port in ports:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(1)
        result = sock.connect_ex((target_ip, port))
        status = "OPEN" if result == 0 else "CLOSED"
        print(f"Port {port}: {status}")
        sock.close()


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python port_scan.py <honeypot-ip>")
        sys.exit(1)
    gentle_port_scan(sys.argv[1], [22, 80, 443, 3389, 1433, 5432])
