#!/bin/bash
# Run Script

# Remove the default NGINX configuration
rm /etc/nginx/conf.d/default.conf

# Remove the default sites html folder
rm -rf /var/www/html


# Sort out Self Sign variables
if [$SELFSIGN_COUNTRY == '']
then
    $SELFSIGN_COUNTRY = 'Undefined'
fi

if [$SELFSIGN_COMMON_NAME == '']
then
    $SELFSIGN_COMMON_NAME = 'Undefined'
fi

if [$SELFSIGN_EMAIL == '']
then
    $SELFSIGN_EMAIL = 'undefined@example.com'
fi

if [$SELFSIGN_ENABLED == 1]
then
   openssl req -subj "/C=$SELFSIGN_COUNTRY/ST=$SELFSIGN_STATE/L=$SELFSIGN_CITY/O=$SELFSIGN_DIS/CN=$SELFSIGN_COMMON_NAME" -x509 -nodes -newkey rsa:2048 -keyout /etc/ssl/private/default-server.key -out /etc/ssl/certs/default-server.crt
fi

if [$CERTBOT_ENABLED == 1]
then
certbot --nginx --non-interactive --redirect --expand --agree-tos -m $EMAIL --domains $CERTBOT_DOMAINS
fi

# Copy configs to conf.d
cp -r /etc/autocert/configs/. /etc/nginx/conf.d/ 

# Restart NGINX
service nginx restart

