import socket
import urllib.request

from urllib.error import URLError


def get_local_primary_ip() -> str:
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(('8.8.8.8', 1))
        ip = s.getsockname()[0]
    except OSError:
        ip = '127.0.0.1'
    finally:
        s.close()
    return ip


def get_public_ip() -> str:
    external_ip_api_endpoint = 'https://api.ipify.org'

    try:
        return urllib.request.urlopen(external_ip_api_endpoint).read().decode('utf-8')
    except (URLError, AttributeError, UnicodeDecodeError):
        return ""


if __name__ == '__main__':
    print(get_local_primary_ip())
    print(get_public_ip())
