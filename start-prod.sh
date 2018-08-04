#!/bin/bash

# This shell script restarts the docker
# sudo sysctl -w vm.max_map_count=262144
sudo docker-compose stop
sudo docker-compose up -d workspace caddy mariadb php-fpm portainer
