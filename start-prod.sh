#!/bin/bash

# This shell script restarts the docker
# sudo sysctl -w vm.max_map_count=262144

if [ "$1" == "provision" ]
then
    # removes all the database data
    sudo rm -rf ~/.qulph/data/mariadb
fi

sudo docker-compose stop

if [ "$1" == "provision" ]
then
    sudo docker-compose up -d --build workspace caddy mariadb php-fpm
elif [ "$1" == "rebuild" ]
then
    sudo docker-compose build --no-cache workspace caddy mariadb php-fpm
    sudo docker-compose up -d workspace caddy mariadb php-fpm
else
    sudo docker-compose up -d workspace caddy mariadb php-fpm
fi

if [ "$1" == "provision" ]
then
    # login to workspace console, all following commands need to be run there
    sudo docker-compose exec workspace bash -c "

            # application dir
            cd /var/www/qulph/application

            # clear product and config images and files
            rm -rf web/files/*.*
            rm -rf web/files/thumbnail/*.*
            rm -rf web/upload/*.*
            rm -rf web/upload/files/*.*
            rm -rf web/upload/images/*.*
            rm -rf web/upload/user-uploads/*.*

            # initialization
            sh install.sh

            # run the interactive installer
            ./installer

            # install demo data
            sh demo.sh


            # ================BEGIN keep initial config as default========================
            rm -rf config/default/ && mkdir config/default
            rsync -a config/*.* config/default/ \
            --exclude=assets-dev.php \
            --exclude=assets-prod.php \
            --exclude=common.php \
            --exclude=console.php \
            --exclude=db.php \
            --exclude=installer.php \
            --exclude=params.php \
            --exclude=sites.json \
            --exclude=web.php
            rsync -a config/.gitignore config/default/


            rm -rf config/configurables-kv/default/ && mkdir config/configurables-kv/default
            rsync -a config/configurables-kv/*.* config/configurables-kv/default/
            rsync -a config/configurables-kv/.gitignore config/configurables-kv/default/


            rm -rf config/configurables-state/default && mkdir config/configurables-state/default
            rsync -a  config/configurables-state/*.* config/configurables-state/default/
            rsync -a config/configurables-state/.gitignore config/configurables-state/default/
            # ================END keep default========================



            # clear cache
            rm -rf runtime/cache/ && mkdir runtime/cache
            rm -rf web/assets/ && mkdir web/assets

            # give proper directory permissions
            chmod 777 -R config/
            chmod 777 -R extensions/DefaultTheme/assets/theme/
            chmod 777 -R web/
            chmod 777 -R runtime/cache

    "
fi
