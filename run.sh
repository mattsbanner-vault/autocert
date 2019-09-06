#!/bin/bash
# Run Script

# Remove the default NGINX configuration
rm /etc/nginx/conf.d/default.conf

# Remove the default sites html folder
rm -rf /var/www/html

# Create a self signed certificate, should the user need it
openssl req -subj "/C=$COUNTRY/" -x509 -nodes -newkey rsa:2048 -keyout /etc/ssl/private/default-server.key -out /etc/ssl/certs/default-server.crt

# Copy configs to conf.d
cp -r /etc/autocert/configs/. /etc/nginx/conf.d/ 

# Run Certbot
certbot --nginx --non-interactive --redirect --expand --agree-tos -m $EMAIL --domains $DOMAINS

# Restart NGINX
service nginx restart