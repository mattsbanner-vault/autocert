#!/bin/bash
# Run Script

# Remove the default NGINX configuration
rm /etc/nginx/conf.d/default.conf

# Remove the default sites html folder
rm -rf /var/www/html

# Copy over the default config
cp /etc/autocert/repo/default.conf /etc/nginx/conf.d/default.conf

# Copy configs to conf.d
cp -r /etc/autocert/configs/. /etc/nginx/conf.d/ 

# Run Certbot
certbot --nginx --non-interactive --redirect --agree-tos -m $EMAIL --domains $DOMAINS

# Restart NGINX
service nginx restart
