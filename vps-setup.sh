apt update
apt install git zsh nmap python3 python3-pip net-tools -y
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
sed -e 's/robbyrussell/gianu/g' $HOME/.zshrc -i
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.zshrc
wget https://go.dev/dl/go1.17.6.linux-amd64.tar.gz
/bin/zsh
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.17.6.linux-amd64.tar.gz
rm go1.17.6.linux-amd64.tar.gz
go get -u github.com/ffuf/ffuf
git clone https://github.com/danielmiessler/SecLists.git
git clone https://github.com/darkoperator/dnsrecon.git
git clone https://github.com/gfek/Lepus.git
