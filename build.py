#######################################
# Imports                             #
#######################################
import subprocess
import yaml


#######################################
# Functions                           #
#######################################

# Run commands on the command line
def bash(command):
    if config["globals"]["mode"] == 'production':
        try:
            subprocess.check_output(['bash', '-c', command])
            return 1
        except subprocess.CalledProcessError as e:
            soft_error(e.output)
            return 0
    else:
        print("App in dev mode. [" + command + "] was skipped.")
        return 1


# Return yaml from path
def load_yaml(path):
    with open(path, 'r') as stream:
        try:
            return yaml.safe_load(stream)
        except yaml.YAMLError as e:
            soft_error(e)


# Check the configuration is valid and set some defaults if not defined
def config_check():
    # Check we have the base structure
    if not config_check_items(0, ['globals', 'selfsign', 'certbot']):
        return 0

    # Check globals for email if needed
    if config['selfsign']['enabled'] or config['certbot']['enabled']:
        if not config_check_items('globals', ['email']):
            return 0

    # Check selfsign has required (if enabled)
    if config["selfsign"]["enabled"]:
        if not config_check_items('selfsign', ['country', 'state', 'city', 'common']):
            return 0

    # Default selfsign to false if not set
    if not config_check_items('selfsign', ['enabled']):
        config['selfsign']['enabled'] = 0

    # Default certbot to false if not set
    if not config_check_items('certbot', ['enabled']):
        config['certbot']['enabled'] = 0

    # Default certbot redirect to false if not set
    if not config_check_items('certbot', ['redirect']):
        config['certbot']['redirect'] = 0

    # Certbot mode not defined. Set to scrape
    if not config_check_items('certbot', ['mode']):
        config['certbot']['mode'] = 'scrape'

    # Check certbot has domains (if enabled and mode is list)
    if config["certbot"]["enabled"] and config['certbot']['mode'] == 'list':
        if not config_check_items('certbot', ['domains']):
            return 0

    return 1


# Check parent array for items
def config_check_items(parent, items):
    # No parent? Check the yaml directly
    if not parent:
        check = config
    else:
        check = config[parent]

    # Loop the items, return false if not in parent
    for item in items:
        if item not in check or not check[item]:
            return 0

    return 1


# Print error Todo - Exception throwing
def soft_error(text):
    print("ERROR: " + text)


def scrape_nginx(): # Todo - Scrape NGINX configs for domains
    print("NOT IMPLEMENTED YET")
    return [0]


#######################################
# Script                              #
#######################################

# Load the config
config = load_yaml("/etc/autocert/config.yml")

# Set app mode to production if not defined in config
if "mode" not in config["globals"]:
    config["globals"]["mode"] = 'production'

# Check the config is valid
if not config_check():
    soft_error('Config invalid / missing parameters')

# Remove the default NGINX configuration
bash("rm /etc/nginx/conf.d/default.conf")

# Copy configs to conf.d
bash("cp -r /etc/autocert/configs/. /etc/nginx/conf.d/")

if config['selfsign']['enabled']:
    bash("openssl req -subj " +
         "/C=" + config['selfsign']['country'] +
         "/ST=" + config['selfsign']['state'] +
         "/L=" + config['selfsign']['city'] +
         "/CN=" + config['selfsign']['common'] +
         " -x509 -nodes -newkey rsa:2048 -keyout /etc/ssl/private/default-server.key -out /etc/ssl/certs/default-server.crt")

if config['certbot']['enabled']:
    if config['certbot']['mode'] == 'list':
        domains = ""

        for domain in config['certbot']['domains']:
            domains = domains + domain + ',' # Todo Must be a neater way of concatenating in Python

        # Todo Trim the last comma or just don't put it there in the first place
    else:
        domains = scrape_nginx()

    redirect = ''
    if config['certbot']['redirect']:
        redirect = ' --redirect '

    bash("certbot --nginx --non-interactive" + redirect + "--expand --agree-tos -m " + config['globals'][
        'email'] + " --domains " + domains)

# Restart NGINX
bash("service nginx restart")
