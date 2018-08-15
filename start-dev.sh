#!/bin/bash

# This shell script restarts the docker
# sudo sysctl -w vm.max_map_count=262144

if [ "$1" == "provision" ]
then
    # removes all the database data
    sudo rm -rf ~/.laradock/data/mariadb
fi

sudo docker-compose stop

if [ "$1" == "provision" -o "$1" == "rebuild" ]
then
    sudo docker-compose build --no-cache workspace nginx mariadb phpmyadmin php-fpm portainer
fi

sudo docker-compose up -d workspace nginx mariadb phpmyadmin php-fpm portainer

if [ "$1" == "provision" ]
then
    # login to workspace console, all following commands need to be run there
    sudo docker-compose exec workspace bash -c "

            # application dir
            cd /var/www/shop/application

            # clear cache
            rm -rf runtime/cache/
            rm -rf web/assets/

            # initialization
            sh install.sh

            # run the interactive installer
            ./installer

            # install demo data
            sh demo.sh

            # give proper directory permissions
            chmod 777 -R config/
            chmod 777 -R extensions/DefaultTheme/assets/theme/
            mkdir web/assets
            chmod 777 -R web/assets

    "
fi
