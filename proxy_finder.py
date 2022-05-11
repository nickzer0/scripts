"""
Grabs a bunch of HTTPS proxies from SSLProxies.org, then checks if they are live on a 5 second timeout.
"""

import requests
from bs4 import BeautifulSoup
from random import choice
from requests.auth import HTTPBasicAuth
from sys import argv
import base64
import lxml

proxy_list = []

def proxy_generator():
    print("[*] Getting list of proxies....")
    page = requests.get("https://sslproxies.org/")
    soup = BeautifulSoup(page.text, 'lxml')
    proxy_table = soup.find(text="Last Checked").find_parent("table")
    for row in proxy_table.find_all("tr")[1:]:
        proxy = ([cell.get_text(strip=True) for cell in row.find_all("td")][0] + ":" + [cell.get_text(strip=True) for cell in row.find_all("td")][1])
        proxy_list.append(proxy)
    print("[*] Got list of " + str(len(proxy_list)) + " proxies!")

def check_proxy():
    print("[*] Checking proxies are live.")
    counter = len(proxy_list)
    while counter > 0:
        try:
            for ip in proxy_list:
                proxy = {'https' : ip }
                print("[*] Trying proxy: " + ip)
                response = requests.request(method='GET', url='https://ipinfo.io/json', proxies=proxy, timeout=5)
                print("[+] Proxy is live!")
                counter -= 1
        except:
            proxy_list.remove(ip)
            print("[!] " + ip + " is dead...")
            counter -= 1
            pass

if __name__ == '__main__':
    proxy_generator()
    proxy = check_proxy()
    print("\n" + "Got list of " + str(len(proxy_list)) + " proxies:")
    for prox in proxy_list:
        print(prox)
