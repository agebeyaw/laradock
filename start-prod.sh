#!/bin/bash

# This shell script restarts the docker
# sudo sysctl -w vm.max_map_count=262144

if [ "$1" == "provision" ]
then
    # removes all the database data
    sudo rm -rf ~/.qulph/data/
fi

sudo docker-compose stop
sudo docker-compose up -d workspace caddy mariadb php-fpm


if [ "$1" == "provision" ]
then
    # login to workspace console, all following commands need to be run there
    sudo docker-compose exec workspace bash -c "

            # application dir
            cd /app/qulph/application

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
