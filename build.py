#!/usr/bin/env python

import subprocess
import yaml

def bash(command):
    try:
        subprocess.check_output(['bash', '-c', command])
    except subprocess.CalledProcessError as e:
        print(e.output)

with open("/etc/autocert/config.yml", 'r') as stream:
    try:
        print(yaml.safe_load(stream))
    except yaml.YAMLError as e:
        print(e)

# Remove the default NGINX configuration
bash("rm /etc/nginx/conf.d/default.conf")

# Go through the config and validate we have everything

# Copy configs to conf.d
bash("cp -r /etc/autocert/configs/. /etc/nginx/conf.d/")

# Restart NGINX
bash("service nginx restart")
