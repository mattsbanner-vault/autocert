FROM mattbanner/nginx-base:latest

RUN \
    # Perform some updates and install the software we need
    apt-get update && apt-get upgrade -yq && \
    apt-get install -y apt-utils software-properties-common git nano && \
    apt-get install -y python3 python3-pip python3-acme python3-certbot python3-mock python3-openssl python3-pkg-resources python3-pyparsing python3-zope.interface && \
    apt-get install -y certbot python-certbot-nginx && \
    pip3 install PyYAML && \
    apt-get update -yq && \
    # Create some directories
    mkdir /etc/autocert && \
    mkdir /etc/autocert/configs && \
    mkdir /etc/autocert/plugins && \
    # Clone some dependencies
    cd /etc/autocert/ && git clone https://github.com/mattsbanner/autocert.git --single-branch --branch local-development repo && \
    # cd /etc/autocert/plugins/ && git clone https://github.com/mattsbanner/pretty-nginx.git && \
    # Ensure we're up to date (build caching)
    cd /etc/autocert/repo && git reset HEAD --hard && git pull && \
    # cd /etc/autocert/plugins/pretty-nginx && git reset HEAD --hard && git pull && \
    # Run the setup script
    chmod 755 /etc/autocert/repo/run.sh

VOLUME ["/var/www/", "/etc/autocert/configs/", "/etc/letsencrypt/"]

EXPOSE 80
EXPOSE 443

CMD python3 /etc/autocert/repo/build.py && tail -f /dev/null
