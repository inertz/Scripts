#!/bin/bash

# Variables
EMAIL="webmaster@inertz.org"  # Your email for Let's Encrypt registration
CERTBOT_PATH="/usr/bin/certbot"  # Path to Certbot
DOMAIN_FILE="domains.txt"  # File containing the list of domains
SSL_CONF_PATH="/etc/httpd/conf.d/ssl.conf"  # Path to Apache SSL configuration

# Check if the domains.txt file exists
if [ ! -f "$DOMAIN_FILE" ]; then
    echo "Domain file '$DOMAIN_FILE' not found!"
    exit 1
fi

# Check if ssl.conf exists
if [ ! -f "$SSL_CONF_PATH" ]; then
    echo "SSL configuration file '$SSL_CONF_PATH' not found!"
    exit 1
fi

# Read the domains from the file and request certificates individually
while IFS= read -r DOMAIN; do
    echo "Requesting SSL certificate for: $DOMAIN"

    # Ensure there is a basic VirtualHost setup for the domain (same DocumentRoot)
    echo "Adding VirtualHost configuration for $DOMAIN in /etc/httpd/conf.d/"
    echo "
<VirtualHost *:80>
    ServerName $DOMAIN
    ServerAlias www.$DOMAIN
    DocumentRoot /var/www/html
    ErrorLog /var/log/httpd/$DOMAIN-error_log
    CustomLog /var/log/httpd/$DOMAIN-access_log combined
</VirtualHost>
" >> /etc/httpd/conf.d/$DOMAIN.conf

    # Request the SSL certificate
    $CERTBOT_PATH --apache --non-interactive --agree-tos --email "$EMAIL" -d "$DOMAIN" -d "www.$DOMAIN"

    # Check if the certificate was issued successfully
    if [ $? -eq 0 ]; then
        echo "SSL certificate successfully issued for: $DOMAIN"

        # Add SSL configuration for the domain to ssl.conf
        echo "Adding SSL configuration for $DOMAIN to $SSL_CONF_PATH"
        echo "
<VirtualHost *:443>
    ServerName $DOMAIN
    ServerAlias www.$DOMAIN
    DocumentRoot /var/www/html

    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/$DOMAIN/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/$DOMAIN/privkey.pem

    <Directory /var/www/html>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
" >> $SSL_CONF_PATH

        # Check if the configuration was added successfully
        if [ $? -eq 0 ]; then
            echo "SSL configuration successfully added for: $DOMAIN"
        else
            echo "Failed to add SSL configuration for: $DOMAIN"
        fi

    else
        echo "Failed to issue SSL certificate for: $DOMAIN"
    fi
done < "$DOMAIN_FILE"

# Test Apache configuration
echo "Testing Apache configuration..."
apachectl configtest

if [ $? -eq 0 ]; then
    echo "Apache configuration is valid."
    echo "Reloading Apache to apply changes..."
    systemctl reload httpd
else
    echo "Apache configuration is invalid! Please check your ssl.conf file."
    exit 1
fi

echo "SSL setup and configuration completed."
