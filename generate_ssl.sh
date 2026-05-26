#!/bin/bash

# This script generates a self-signed SSL certificate for Apache on Ubuntu 20.04.
# It's intended for development or testing environments where a trusted CA certificate is not required.

# Define certificate details
CERT_DIR="/etc/ssl/private"
CERT_FILE="/etc/ssl/certs/apache-selfsigned.crt"
KEY_FILE="/etc/ssl/private/apache-selfsigned.key"
DOMAIN="your_domain.com" # Replace with your domain or IP address

# Create SSL directory if it doesn't exist
if [ ! -d "$CERT_DIR" ]; then
  sudo mkdir -p "$CERT_DIR"
  sudo chmod 700 "$CERT_DIR"
fi

# Generate the private key and certificate
# -x509: Creates a self-signed certificate
# -nodes: No DES, don't encrypt the private key
# -days 365: Certificate valid for 365 days
# -newkey rsa:2048: Generates a new RSA private key of 2048 bits
# -keyout: Output file for the private key
# -out: Output file for the certificate
# -subj: Subject information for the certificate
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout "$KEY_FILE" -out "$CERT_FILE" -subj "/C=TR/ST=YourState/L=YourCity/O=YourOrganization/OU=YourUnit/CN=$DOMAIN"

# Set correct permissions for the key file
sudo chmod 600 "$KEY_FILE"

# Configure Apache to use the self-signed certificate
# This assumes you have a default SSL configuration or are creating one.
# You might need to adjust these paths based on your Apache setup.
APACHE_SSL_CONF="/etc/apache2/sites-available/default-ssl.conf"

# Backup the original SSL configuration
sudo cp "$APACHE_SSL_CONF" "$APACHE_SSL_CONF.bak"

# Update the SSL configuration with the generated certificate and key
# SSLEngine on: Enables SSL/TLS engine
# SSLCertificateFile: Path to the certificate file
# SSLCertificateKeyFile: Path to the private key file
sudo sed -i "s|SSLCertificateFile.*|SSLCertificateFile    $CERT_FILE|" "$APACHE_SSL_CONF"
sudo sed -i "s|SSLCertificateKeyFile.*|SSLCertificateKeyFile $KEY_FILE|" "$APACHE_SSL_CONF"

# Enable the SSL module and the default SSL site
sudo a2enmod ssl
sudo a2ensite default-ssl.conf

# Test Apache configuration
sudo apache2ctl configtest

# Restart Apache to apply changes
sudo systemctl restart apache2

echo "Self-signed SSL certificate generated and Apache configured."
echo "Access your site at: https://$DOMAIN"
echo "Note: Your browser will show a security warning as this certificate is not trusted by a public CA."