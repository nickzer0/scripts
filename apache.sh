#!/bin/bash

# Configures Apache2 on a black Ubuntu box with TLS

dnsIP=$(dig $1 @8.8.8.8 +short)
localIP=`curl -s ifconfig.me`

if [ $dnsIP != $localIP ]
then
        echo "DNS hasn't propagated yet, wait a few minutes..."
        exit 0
else
        echo "Installing Apache2"
        apt install -qq apache2 -y &> /dev/null
        echo "Disabling UFW"
        sudo ufw disable &> /dev/null
        sed 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf -i
        a2enmod rewrite proxy proxy_http ssl headers &> /dev/null
        systemctl restart apache2 &> /dev/null
        echo "Installing Certbot"
        snap install --classic certbot &> /dev/null
        ln -s /snap/bin/certbot /usr/bin/certbot &> /dev/null
        echo "Requesting certificate for "$1""
        certbot certonly --apache --agree-tos --register-unsafely-without-email --domains $1 -n &> /dev/null
        echo "Editing Apache config"
        sed 's#/etc/ssl/certs/ssl-cert-snakeoil.pem#/etc/letsencrypt/live/'$1'/fullchain.pem#g' -i /etc/apache2/sites-available/default-ssl.conf
        sed 's#/etc/ssl/private/ssl-cert-snakeoil.key#/etc/letsencrypt/live/'$1'/privkey.pem\n\t\tInclude /etc/letsencrypt/options-ssl-apache.conf#g' -i /etc/apache2/sites-available/default-ssl.conf
        sed 's#DocumentRoot /var/www/html#DocumentRoot /var/www/html\n\t\tServerName '$1'\n\t\tServerAlias www.'$1'#g' -i /etc/apache2/sites-available/default-ssl.conf
        sed 's#SSLEngine on#SSLEngine on\n\tSSLProtocol all -SSLv2 -SSLv3\n\tSSLCipherSuite ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:!DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA\n\tSSLHonorCipherOrder on\n\tSSLCompression off\n\tSSLOptions +StrictRequire\n\tSSLProxyEngine On\n\tSSLProxyVerify none\n\tSSLProxyCheckPeerCN off\n\tSSLProxyCheckPeerName off\n\tSSLProxyCheckPeerExpire off#g' /etc/apache2/sites-available/default-ssl.conf -i
        echo "Restarting Apache..."
        a2ensite default-ssl.conf &> /dev/null
        systemctl reload apache2 &> /dev/null
        service apache2 restart &> /dev/null
        echo "Done!"
fi
