#!/bin/bash

dnsIP=$(dig $1 @8.8.8.8 +short)
localIP=`curl -s ifconfig.me`

if [ "$(id -u)" != "0" ]; then
   echo "[!] This script must be run as root" 1>&2
   exit 1
fi

if [ $# -eq 0 ]; then
        echo "[!] Usage: ./setup.sh <domain.com>"
        exit 0
fi

while [ "$dnsIP" != "$localIP" ]; do
        echo "[!] DNS hasn't propagated yet, waiting 10 seconds..."
        sleep 10
        dnsIP=$(dig $1 @8.8.8.8 +short)
done
	    echo "[+] DNS has propagated!"    
		echo "[+] Updating packages"
		apt update &> /dev/null
        echo "[+] Installing Apache2"
        apt install -qq apache2 -y &> /dev/null
        echo "[+] Installing Net-tools"
        apt install -qq net-tools -y &> /dev/null
        sed 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf -i
        a2enmod rewrite proxy proxy_http ssl headers &> /dev/null
        systemctl restart apache2 &> /dev/null
        echo "[+] Installing Certbot"
        snap install --classic certbot &> /dev/null
        ln -s /snap/bin/certbot /usr/bin/certbot &> /dev/null
        echo "[+] Requesting certificate for "$1""
        certbot certonly --apache --agree-tos --register-unsafely-without-email --domains $1 -n &> /dev/null
        echo "[+] Editing Apache config"
        sed 's#/etc/ssl/certs/ssl-cert-snakeoil.pem#/etc/letsencrypt/live/'$1'/fullchain.pem#g' -i /etc/apache2/sites-available/default-ssl.conf
        sed 's#/etc/ssl/private/ssl-cert-snakeoil.key#/etc/letsencrypt/live/'$1'/privkey.pem\n\t\tInclude /etc/letsencrypt/options-ssl-apache.conf#g' -i /etc/apache2/sites-available/default-ssl.conf
        sed 's#DocumentRoot /var/www/html#DocumentRoot /var/www/html\n\t\tServerName '$1'\n\t\tServerAlias www.'$1'#g' -i /etc/apache2/sites-available/default-ssl.conf
        sed 's#SSLEngine on#SSLEngine on\n\tSSLProtocol all -SSLv2 -SSLv3\n\tSSLCipherSuite ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:!DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA\n\tSSLHonorCipherOrder on\n\tSSLCompression off\n\tSSLOptions +StrictRequire\n\tSSLProxyEngine On\n\tSSLProxyVerify none\n\tSSLProxyCheckPeerCN off\n\tSSLProxyCheckPeerName off\n\tSSLProxyCheckPeerExpire off#g' /etc/apache2/sites-available/default-ssl.conf -i
        echo "[+] Restarting Apache..."
        a2ensite default-ssl.conf &> /dev/null
        systemctl reload apache2 &> /dev/null
        service apache2 restart &> /dev/null
        echo "[+] Installing Java..."
        sudo apt install -qq openjdk-11-jdk -y
        sudo update-java-alternatives -s java-1.11.0-openjdk-amd64
        echo "[+] Exporting certificate..."
        openssl pkcs12 -export -in /etc/letsencrypt/live/$1/cert.pem -inkey /etc/letsencrypt/live/$1/privkey.pem -out cert.p12 -name redir.store -passout pass:password
        keytool -importkeystore -srckeystore cert.p12 -srcstoretype pkcs12 -destkeystore redir.store -deststoretype jks -srcstorepass password -deststorepass password
        echo "[+] Done! Copy 'redir.store' to TeamServer"
