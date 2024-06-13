#!/bin/bash
apt update
apt install -y ca-certificates curl apt-transport-https lsb-release gnupg apache2
curl -sL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor | sudo tee /usr/share/keyrings/microsoft-archive-keyring.gpg > /dev/null
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
apt update
apt install -y azure-cli
echo Hello from VM `hostname` > /var/www/html/index.html
systemctl enable apache2
systemctl restart apache2