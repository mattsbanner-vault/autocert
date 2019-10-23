FROM mattbanner/nginx-base:latest

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

RUN \
    # Perform some updates and install the software we need
    apt update && apt upgrade -yq && \
    apt install -y python3-acme python3-certbot python3-mock python3-openssl python3-pkg-resources python3-pyparsing python3-zope.interface && \
    apt install -y certbot python-certbot-nginx && \
    apt update -yq && \

    # Create some directories
    mkdir /etc/autocert && \
    mkdir /etc/autocert/configs && \
    mkdir /etc/autocert/plugins && \

    # Clone some dependencies
    cd /etc/autocert/ && git clone https://github.com/mattsbanner/autocert.git repo && \
    cd /etc/autocert/plugins/ && git clone https://github.com/mattsbanner/pretty-nginx.git && \

    # Ensure we're up to date (build caching)
    cd /etc/autocert/repo && git reset HEAD --hard && git pull && \ 
    cd /etc/autocert/plugins/pretty-nginx && git reset HEAD --hard && git pull && \

    # Run the setup script
    chmod 755 /etc/autocert/repo/run.sh

VOLUME ["/var/www", "/etc/autocert/configs", "/etc/letsencrypt"]

EXPOSE 80
EXPOSE 443

CMD /etc/autocert/repo/run.sh $EMAIL $SELFSIGN_ENABLED $SELFSIGN_COUNTRY $SELFSIGN_STATE $SELFSIGN_DIS $SELFSIGN_CITY $SELFSIGN_COMMON_NAME $CERTBOT_ENABLED $CERTBOT_DOMAINS && tail -f /dev/null


