#!/bin/bash
if [ -z $1 ]; 
  then 
    echo "No MySQL user password set! aborting"
    exit 1
fi

MYSQL_IP=`sudo docker inspect mysql-mediawiki | grep -Po '(?<="IPAddress": ")\d+\.\d+\.\d+\.\d+' | head -n1`
echo "MySQL-Server IP:" $MYSQL_IP

SOLR_IP=`sudo docker inspect bluespice-solr | grep -Po '(?<="IPAddress": ")\d+\.\d+\.\d+\.\d+' | head -n1`
echo "SOLR-Server IP:" $SOLR_IP

echo "MySQL user password:" $1

sed -i 's/\$wgDBpassword.*/\$wgDBpassword = "'$1'";/g' src/LocalSettings.php
sed -i 's/\$wgDBserver.*/\$wgDBserver = "'$MYSQL_IP'";/g' src/LocalSettings.php

SECRET_KEY=`head -c32 </dev/urandom|xxd -p -u -c64`
sed -i 's/\$wgSecretKey.*/\$wgSecretKey = "'$SECRET_KEY'";/g' src/LocalSettings.php

UPGRADE_KEY=`head -c8 </dev/urandom|xxd -p -u`
sed -i 's/\$wgUpgradeKey.*/\$wgUpgradeKey = "'$UPGRADE_KEY'";/g' src/LocalSettings.php
