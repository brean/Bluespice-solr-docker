#!/bin/bash
if [ -z $MYSQL_ROOT ]; 
  then 
    echo "No MySQL root password set! aborting"
    exit 1
fi
if [ -z $MYSQL_USER ]; 
  then 
    echo "No MySQL user password set! aborting"
    exit 1
fi

MYSQL_IP=`sudo docker inspect mysql-mediawiki | grep -Po '(?<="IPAddress": ")\d+\.\d+\.\d+\.\d+' | head -n1`
echo "MySQL-Server IP:" $MYSQL_IP

SOLR_IP=`sudo docker inspect bluespice-solr | grep -Po '(?<="IPAddress": ")\d+\.\d+\.\d+\.\d+' | head -n1`
echo "SOLR-Server IP:" $SOLR_IP

echo "MySQL root password:" $MYSQL_ROOT
echo "MySQL user password:" $MYSQL_USER

echo "update database"
sudo docker exec -it mysql-mediawiki mysql -u root -p$MYSQL_ROOT -e "CREATE DATABASE mediawiki; CREATE USER 'wikiuser'@'%'  IDENTIFIED BY '$MYSQL_USER'; GRANT ALL ON mediawiki.* TO 'wikiuser'@'%'"
