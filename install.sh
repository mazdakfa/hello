#!/bin/bash

# Script for complete installation on Ubuntu Server

# Update system packages
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install necessary packages
echo "Installing Nginx and Certbot..."
sudo apt install nginx certbot python3-certbot-nginx -y

# Prompt for Subdomain Configuration
read -p "Enter your subdomain (e.g., sub.example.com): " SUBDOMAIN
read -p "Enter your email address for SSL certificate notifications: " EMAIL

# Setup Nginx server block
echo "Setting up Nginx server block for $SUBDOMAIN..."
sudo tee /etc/nginx/sites-available/$SUBDOMAIN > /dev/null <<EOF
server {
    listen 80;
    server_name $SUBDOMAIN;

    location / {
        root /var/www/$SUBDOMAIN;
        index index.html index.htm;
    }

    # Redirect HTTP to HTTPS
    return 301 https://\$server_name\$request_uri;
}
EOF

# Enable the new server block
sudo ln -s /etc/nginx/sites-available/$SUBDOMAIN /etc/nginx/sites-enabled/
sudo nginx -t

# Create webroot directory
sudo mkdir -p /var/www/$SUBDOMAIN
echo "<h1>This is the $SUBDOMAIN server block!</h1>" | sudo tee /var/www/$SUBDOMAIN/index.html

# Obtain SSL certificate with Certbot
echo "Obtaining SSL certificate for $SUBDOMAIN..."
sudo certbot --nginx -d $SUBDOMAIN --agree-tos --email $EMAIL --non-interactive

# Reload Nginx
echo "Reloading Nginx..."
sudo systemctl reload nginx

echo "Installation completed successfully!"