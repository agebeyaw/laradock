#!/bin/bash

# This shell script restarts the docker
# sudo sysctl -w vm.max_map_count=262144

 if [ -z $1 ]
 then
    echo "please provide sitename"
 else

    read -p "Existing data will be erased! Are you sure to create site $1? (y/n) " -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then

        ./remove-site-prod.sh $1

        echo "Working on creating site ===$1===="
        sudo docker-compose exec mariadb bash -c "
             mysql -uroot -proot -e \"CREATE DATABASE $1\"
             mysql -uroot -proot -e \"GRANT ALL PRIVILEGES ON $1.* TO $1@'%' IDENTIFIED BY '$1'\"
             mysql -uroot -proot -e \"GRANT ALL PRIVILEGES ON $1.* TO $1@localhost IDENTIFIED BY '$1'\"
         "

         sudo docker-compose exec workspace bash -c "

            # application dir
            cd /var/www/qulph/application

            sh update-dependencies.sh

            # run the interactive installer
            ./installer install/index --siteID=$1

            # install demo data
            sh demo.sh

            mkdir config/$1

            rsync -a config/*.* config/$1/ \
            --exclude=assets-dev.php \
            --exclude=assets-prod.php \
            --exclude=common.php \
            --exclude=console.php \
            --exclude=db.php \
            --exclude=installer.php \
            --exclude=params.php \
            --exclude=sites.json \
            --exclude=web.php
            rsync -a config/.gitignore config/$1/

            mkdir config/configurables-kv/$1
            rsync -a config/configurables-kv/*.* config/configurables-kv/$1/
            rsync -a config/configurables-kv/.gitignore config/configurables-kv/$1/


            mkdir config/configurables-state/$1
            rsync -a  config/configurables-state/*.* config/configurables-state/$1/
            rsync -a config/configurables-state/.gitignore config/configurables-state/$1/


            # ===== create required file directories in webroot ====

            mkdir web/upload/$1
            mkdir web/upload/$1/files
            mkdir web/upload/$1/images
            mkdir web/upload/$1/user-uploads

            mkdir web/files/$1
            mkdir web/files/$1/thumbnail

            mkdir web/images/icons/$1

            # ========= copy default files ==========

            # take icon files from main site
            rsync -ra web/images/icons/*.* web/images/icons/$1

            # take demo product images
            rsync -ra web/files/*.* web/files/$1/
            rsync -ra web/files/.gitignore web/files/$1/
            rsync -ra web/files/thumbnail/*.* web/files/$1/thumbnail/
            rsync -ra web/files/thumbnail/.gitignore web/files/$1/thumbnail/

            # take upload files
            rsync -ra web/upload/*.* web/upload/$1/
            rsync -ra web/upload/.gitignore web/upload/$1/
            rsync -ra web/upload/images/*.* web/upload/$1/images
            rsync -ra web/upload/images/.gitignore web/upload/$1/images
            rsync -ra web/upload/files/*.* web/upload/$1/files
            rsync -ra web/upload/files/.gitignore web/upload/$1/files
            rsync -ra web/upload/user-uploads/*.* web/upload/$1/user-uploads
            rsync -ra web/upload/user-uploads/.gitignore web/upload/$1/user-uploads

            # ========= cache n permissions =========

            # clear cache
            rm -rf runtime/cache/ && mkdir runtime/cache
            rm -rf web/assets/ && mkdir web/assets

            # give proper directory permissions
            chmod 777 -R config/
            chmod 777 -R web/
            chmod 777 -R runtime/cache
         "


    fi
fi