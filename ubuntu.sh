#!/bin/bash

goUrl=$(curl https://go.dev/dl/ -s | grep "download" | grep ".tar.gz" | head -n 1 | cut -d '"' -f 4)
goVer=$(echo $goUrl | cut -d '/' -f 3)
packages=(nmap apache2 net-tools python3 zsh terraform ansible)

echo -ne "\r[+] Installing packages..."
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - &> /dev/null
apt-add-repository -y "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" &> /dev/null
apt-get update &> /dev/null

for i in "${packages[@]}"
do
  apt-get -y install $i > /dev/null
done

echo -ne "\r\033[K                        "
echo -ne "\r[+] Installing latest version of Go..."
wget https://go.dev$goUrl -q
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.20.2.linux-amd64.tar.gz 2>&1 >/dev/null
echo -ne "\r\033[K                        "
echo -ne "\r[+] Configuring zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended > /dev/null
echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.zshrc
sed -e 's/robbyrussell/gianu/g' $HOME/.zshrc -i
echo -ne "\r\033[K                        "
echo -ne "\r[+] Done!\n"
