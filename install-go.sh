#!/bin/bash

# Installs latest version of Go.

if (( $EUID != 0 )); then
    echo "[+] Please run as root."
    exit
fi

echo -ne "\r[+] Installing latest Version of Go..."
goUrl=$(curl https://go.dev/dl/ -s | grep "download" | grep ".tar.gz" | head -n 1 | cut -d '"' -f 4)
goVer=$(echo $goUrl | cut -d '/' -f 3)
wget https://go.dev$goUrl -q
rm -rf /usr/local/go && tar -C /usr/local -xzf $goVer &> /dev/null
echo -ne "\r\033[K                        "
echo -ne '\r[+] Installed: '$goVer'' | cut -d "-" -f 1
