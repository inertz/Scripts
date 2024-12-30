#!/bin/bash

# Ensure the script is run with sudo privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run with sudo!"
    exit 1
fi

# Prompt for the SSL certificate name to be removed
echo "Enter the name of the SSL certificate to remove (e.g., domain.com):"
read CERT_NAME

# Delete the SSL certificate using Certbot
echo "Deleting SSL certificate for $CERT_NAME..."
certbot delete --cert-name "$CERT_NAME"

# Check if the SSL certificate was successfully deleted
if [ $? -eq 0 ]; then
    echo "SSL certificate $CERT_NAME successfully deleted!"
else
    echo "Failed to delete SSL certificate $CERT_NAME."
    exit 1
fi

# Backup the ssl.conf file before making changes
echo "Backing up the ssl.conf file..."
cp /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.bak

# Remove all SSL-related configurations in ssl.conf
echo "Removing SSL configuration in ssl.conf for $CERT_NAME..."
sed -i "/<VirtualHost \*:443>/,/<\/VirtualHost>/d" /etc/httpd/conf.d/ssl.conf

# Check if changes were successfully made
if [ $? -eq 0 ]; then
    echo "SSL configuration for $CERT_NAME has been successfully removed from ssl.conf."
else
    echo "Failed to remove SSL configuration for $CERT_NAME from ssl.conf."
    exit 1
fi

# Remove domain-specific configuration files in conf.d
echo "Removing related configurations for $CERT_NAME from /etc/httpd/conf.d/..."
rm -f /etc/httpd/conf.d/$CERT_NAME.conf

# Check if the domain-specific configuration was successfully deleted
if [ $? -eq 0 ]; then
    echo "Configuration for $CERT_NAME successfully removed!"
else
    echo "Failed to remove configuration for $CERT_NAME."
    exit 1
fi

# Test Apache configuration for errors
echo "Testing Apache configuration..."
apachectl configtest

if [ $? -eq 0 ]; then
    echo "Apache configuration is valid."
else
    echo "There are errors in the Apache configuration!"
    exit 1
fi

# Restart the Apache service
echo "Restarting Apache..."
systemctl restart httpd

if [ $? -eq 0 ]; then
    echo "Apache restarted successfully!"
else
    echo "Failed to restart Apache!"
    exit 1
fi
