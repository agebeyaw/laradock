#!/bin/bash

# This shell script restarts the docker
# sudo sysctl -w vm.max_map_count=262144

 if [ -z $1 ]
 then
    echo "please provide sitename"
 else

    read -p "WARNING!!! All site data for ($1) including db will be removed! Are you sure to proceed now? (y/n) " -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then

        echo "DELETING site ===$1===="

        sudo docker-compose exec mariadb bash -c "
             mysql -uroot -proot -e \"DROP DATABASE IF EXISTS $1\"
             mysql -uroot -proot -e \"DROP USER IF EXISTS $1@'%'\"
             mysql -uroot -proot -e \"DROP USER IF EXISTS $1@localhost\"
         "

         sudo docker-compose exec workspace bash -c "

            # application dir
            cd /var/www/shop/application


            rm -rf config/$1/
            rm -rf config/configurables-kv/$1/
            rm -rf config/configurables-state/$1

            # remove all site files
            rm -rf web/upload/$1
            rm -rf web/files/$1
            rm -rf web/images/icons/$1

            # clear cache
            rm -rf runtime/cache/ && mkdir runtime/cache
            chmod 777 -R runtime/cache
         "

    fi
fi