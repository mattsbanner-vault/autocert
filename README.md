# AutoCert
AutoCert is an NGINX Docker Container with automated Certbot and OpenSSL certificates.

## Issues
Please report all issues on [GitHub](https://github.com/mattsbanner/autocert/issues). Comments on DockerHub are not monitored.

## Configuration
You will need to mount the configuration file to your Docker container. An example can be found in [config.example.yml](config.example.yml). The configuration file is required but not all of the attributes within are.

If setting *selfsign* or *certbot* - enabled to false. All other attributes within that section can be removed.

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

3. Build and run the Docker run command.
    ```
    docker run \
    --name AutoCert \
    -d \
    -e DOMAINS="site1.example.com,site2.example.com" \
    -e EMAIL="youremailforcertbot@example.com" \
    -e COUNTRY="GB" \
    -v /home/user/container/sites:/var/www/ \
    -v /home/user/container/nginx:/etc/autocert/configs/ \
    -v /home/user/container/letsencrypt:/etc/letsencrypt \
    -p 80:80 \
    -p 443:443 \
    mattbanner/autocert:latest
    ```

    * Fill `DOMAINS` with a comma-separated list of the domains you are hosting
    * Fill `EMAIL` with a valid email for Cerbot notifications
    * Fill `COUNTRY` with your two letter country code
    * Change volume mounts to the correct directories. One for sites, one for Lets Encrypt and one for the NGINX configurations.
    * Change the port numbers to match what you have forwarded at your firewall (Optional)
