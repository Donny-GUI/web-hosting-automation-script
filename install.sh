#!/bin/bash


# need website name, dbname, dbuser, dbpassword, localhost 

if [[ $# -ne 5 ]]; then
   echo "Usage: $0 <website name> <db name> <db user> <db password> <localhost>" >&5
   exit 1
fi

# sudo check
if [[ $(id -u) -ne 0 ]]; then
   echo "This script must be run as root. Please use sudo." >&2
   exit 1
fi


# Update the package list and upgrade existing packages
sudo apt-get update
sudo apt-get upgrade -y

# Install required packages for web hosting
sudo apt-get install -y apache2 mysql-server php libapache2-mod-php php-mysql python3

# Configure Apache
sudo a2enmod rewrite
sudo systemctl restart apache2

# Configure MySQL
sudo mysql_secure_installation

# Create a new MySQL user and database for your website
sudo mysql -u root -p << EOF
CREATE DATABASE $2;
CREATE USER '$3'@'$5' IDENTIFIED BY '$4';
GRANT ALL PRIVILEGES ON $2.* TO '$3'@'$5';
FLUSH PRIVILEGES;
EOF

# Create a new virtual host configuration file for your website
sudo touch /etc/apache2/sites-available/$1.com.conf

# Add the following configuration to the file and save it
"<VirtualHost *:80>\n" >> /etc/apache2/sites-available/$1.com.conf
"    ServerName $1\n" >> /etc/apache2/sites-available/$1.com.conf
"    ServerAlias $1.com\n" >> /etc/apache2/sites-available/$1.com.conf
"    DocumentRoot /var/www/$1.com/public_html\n" >> /etc/apache2/sites-available/$1.com.conf
"    ErrorLog /var/www/$1.com/error.log\n" >> /etc/apache2/sites-available/$1.com.conf
"    CustomLog /var/www/$1.com/access.log combined\n" >> /etc/apache2/sites-available/$1.com.conf
"</VirtualHost>\n" >> /etc/apache2/sites-available/$1.com.conf

# Enable the new virtual host and restart Apache
sudo a2ensite $1.com.conf
sudo systemctl reload apache2

# Create the directory structure for your website files
sudo mkdir -p /var/www/$1.com/public_html
sudo chown -R $USER:$USER /var/www/$1.com/public_html
sudo chmod -R 755 /var/www/$1.com

# Create a test index.php file in your website's public_html directory
echo "<?php phpinfo(); ?>" > /var/www/$1.com/public_html/index.php

