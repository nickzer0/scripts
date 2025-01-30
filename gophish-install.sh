#!/bin/bash

# Update package lists
sudo apt update

# Install Golang
sudo apt install -y golang-go

# Clone the Gophish repository
git clone https://github.com/gophish/gophish

# Modify various Gophish files
sed -i 's/X-Gophish-Contact/X-Contact/g' gophish/models/email_request_test.go
sed -i 's/X-Gophish-Contact/X-Contact/g' gophish/models/maillog.go
sed -i 's/X-Gophish-Contact/X-Contact/g' gophish/models/maillog_test.go
sed -i 's/X-Gophish-Contact/X-Contact/g' gophish/models/email_request.go
sed -i 's/X-Gophish-Signature/X-Signature/g' gophish/webhook/webhook.go
sed -i 's/const ServerName = "gophish"/const ServerName = "IGNORE"/' gophish/config/config.go
sed -i 's/const RecipientParameter = "rid"/const RecipientParameter = "keyname"/g' gophish/models/campaign.go

# Replace phish.go with custom version
rm gophish/controllers/phish.go
wget https://raw.githubusercontent.com/nickzer0/sneaky_gophish/refs/heads/main/files/phish.go -O gophish/controllers/phish.go

# Download a custom 404.html template
wget https://raw.githubusercontent.com/nickzer0/sneaky_gophish/refs/heads/main/files/404.html -O gophish/templates/404.html

# Build Gophish
cd gophish
go get -v && go build -v

# Modify config.json
sed -i 's/127.0.0.1/0.0.0.0/g' config.json

# Run Gophish
screen -S gophish sudo ./gophish
