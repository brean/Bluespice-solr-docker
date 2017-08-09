# Bluespice-solr-docker
Dockerfile and stuff to have a bluespice installation with solr running quickly - based on [aneesh14/docker-mediawiki](https://hub.docker.com/r/aneesh14/docker-mediawiki/)

Overview
--------
We will have three docker container:

1. mysql-server running inside the first container that will provide the database for our mediawiki.
1. a second docker container that we build ourself from the Dockerfile provided by this repo.
1. a third docker container providing the solr service (we use the one [on the docker hub](https://hub.docker.com/r/bluespice/solr/) ).

Configuration
-------------
Configure the src/LocalSettings.php. You like to change the $wgDBpassword to your MySQL-Password, $wgSecretKey to a 64-diget hex value and $wgUpgradeKey to a 16-diget hex value as well as the MySQL-Server ip for $wgDBserver. Take a look at the config.sh file that sets these parameters automatically.

You might also want to change the $wgServer, $wgSitename, $wgEmergencyContact and $wgPasswordSender, $language. 

Note that I default to german (de)!

Installation
------------
Note that I use two different MySQL-Passwords here: $MYSQL_ROOT_PASSWORD and $MYSQL_USER_PASSWORD. You want to set those to something more useful at the start.

- install docker for your system (e.g. [Docker CE for Ubuntu](https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/))
- run mysql 
```
sudo docker run --name mysql-mediawiki -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD -d mysql/mysql-server:5.7
```
- run solr
```
sudo docker run --name bluespice-solr -d bluespice/solr:REL1_27
```
- configure the src/LocalSettings.php (or run `MYSQL_ROOT=$MYSQL_ROOT_PASSWORD MYSQL_USER=$MYSQL_USER_PASSWORD sh config.sh` to change parts of the file automatically and create the MySQL-User)
- If you did not run the config.sh-script you need to create the database and grant access rights to a new user on the mysql-server like this (Note that we allow access from ANY other ip in our local dockerverse, you might want to change that if you are sure about the IP of your mediawiki-server):
```
sudo docker exec -it mysql-mediawiki mysql -u root -p$MYSQL_ROOT_PASSWORD -e "CREATE DATABASE mediawiki; CREATE USER 'wikiuser'@'%'  IDENTIFIED BY '$MYSQL_USER_PASSWORD'; GRANT ALL ON mediawiki.* TO 'wikiuser'@'%'";
```

- create the docker container
```
sudo docker build -t mediawiki .
```
- start the docker container (note that I forward to port 3000 because I use an nginx on the host machine that also provides other services)
```
sudo docker run -e MEDIAWIKI_DB_USER=wikiuser -e MEDIAWIKI_DB_PASSWORD=$MYSQL_USER_PASSWORD --name wiki -p 3000:80 --link mysql-mediawiki:mysql --link bluespice-solr:solr -d mediawiki
```
- run the update-script:
```
sudo docker run -e MEDIAWIKI_DB_USER=wikiuser -e MEDIAWIKI_DB_PASSWORD=$MYSQL_USER_PASSWORD --name wiki -p 3000:80 --link mysql-mediawiki:mysql --link bluespice-solr:solr -d mediawiki
```
- go to the config-page of your newly installed wiki and configure the wiki:




Troubleshooting
---------------
Make sure you setup the MySQL-Server first and verify that its ip is 172.17.0.2. If not change that in the LocalSettings.php .

Future Work
-----------
The configuration of the LocalSettings.php could be much nicer integrated with docker and the mysql-user generation could be automated.
An ansible and/or bash-script for this would be nice.
