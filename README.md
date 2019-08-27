# AutoCert
AutoCert is an NGINX Docker Container with automatic Certbot SSL certificates.

Rather than building this image from the ground up (Linux image with NGINX install), this is built on top off the official stable NGINX image - helping to ensure the NGINX installation and configuration is valid / up to date.

## Install
NGINX is great for shared hosting enviroments, so in the following example we're going to be hosting `site1.example.com` and `site2.example.com`.

1. Create some NGINX configurations and save in a folder ready to be mounted as a volume. The below works as a basic example. You only need to write a configuration for HTTP as the container takes care of creating the HTTPS rules. All HTTP traffic will be redirected to HTTPS. Your NGINX configurations must end in `.conf`, they will be copied into `/etc/nginx/conf.d`.

    site1.conf
    ```
    server {
        listen       80;
        server_name  site1.example.com;

        location / {
            root   /var/www/site1/;
            index  index.html index.htm;
        }
    }
    ```

    site2.conf
    ```
    server {
        listen       80;
        server_name  site2.example.com;

        location / {
            root   /var/www/site2/;
            index  index.html index.htm;
        }
    }
    ```

2. Create folders for the site sub-directories to sit in, this parent folder will be mounted as a volume.

    ```
    sites-volume/
        site1/
        site2/
    ```

3. Build the Docker run command. You will need to perform the following to this command
    * Replace `DOMAINS` with a comma-separated list of the domains you are hosting
    * Replace `EMAIL` with a valid email for Cerbot notifications
    * Change both volume mounts to the correct directories. One for your sites, one for the NGINX configurations.
    * Change the port numbers to match what you have forwarded at your firewall (Optional)

    ```
    docker run \
    --name AutoCert \
    -d \
    -e DOMAINS="site1.example.com, site2.example.com" \
    -e EMAIL="youremailforcertbot@example.com" \
    -v /home/user/sites-volume:/var/www/ \
    -v /home/user/config-volume:/etc/autocert/configs/ \
    -p 80:80 \
    -p 443:443 \
    mattbanner/autocert
    ```
