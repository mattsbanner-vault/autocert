FROM nginx:stable

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

RUN \
    apt update && apt upgrade -yq && \
    apt install -y apt-utils software-properties-common git openssl && \
    apt install -y python3-acme python3-certbot python3-mock python3-openssl python3-pkg-resources python3-pyparsing python3-zope.interface && \
    apt install -y certbot python-certbot-nginx && \
    apt update -yq && \
    mkdir /etc/autocert && \
    mkdir /etc/autocert/configs && \
    cd /etc/autocert/ && git clone https://github.com/mattsbanner/autocert.git repo && \
    # Ensure we're up to date (build caching)
    cd /etc/autocert/repo && git reset HEAD --hard && git pull && \ 
    chmod 755 /etc/autocert/repo/run.sh

VOLUME ["/var/www/html", "/etc/autocert/configs"]

EXPOSE 80
EXPOSE 443

CMD /etc/autocert/repo/run.sh $DOMAINS $EMAIL $COUNTRY && tail -f /dev/null