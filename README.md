# Bluespice-solr-docker
Dockerfile and stuff to have a bluespice installation with solr running quickly - based on [aneesh14/docker-mediawiki](https://hub.docker.com/r/aneesh14/docker-mediawiki/)

Overview
--------
We will have three docker container:

1. mysql-server running inside the first container that will provide the database for our mediawiki.
1. a second docker container that we build ourself from the Dockerfile provided by this repo.
1. a third docker container providing the solr service (we use the one [on the docker hub](https://hub.docker.com/r/bluespice/solr/) ).

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
- run the config.sh-script to create the database and grant access rights or do it manually like this (Note that we allow access from ANY other ip in our local dockerverse, you might want to change that if you are sure about the IP of your mediawiki-server):
```
sudo docker exec -it mysql-mediawiki mysql -u root -p$MYSQL_ROOT_PASSWORD -e "CREATE DATABASE mediawiki; CREATE USER 'wikiuser'@'%'  IDENTIFIED BY '$MYSQL_USER_PASSWORD'; GRANT ALL ON mediawiki.* TO 'wikiuser'@'%'";
```
(You might want to write save the output of the config.sh-script to some file for later use)

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
- go to the config-page of your newly installed wiki and configure the wiki: http://localhost:3000/ use the values provided by config.sh

- (optional) configure your nginx to point to the correct page (e.g. [nginx_service.conf](https://gist.github.com/brean/e150a6ba3fa193e5fe6eb29f2f4d3046) )

- save the LocalConfig.php in your users home/Downloads folder (firefox default) and deploy it to your mediawiki-docker installation:

```
sudo docker cp ~/Downloads/LocalSettings.php wiki:/var/www/html/LocalSettings.php
```
- go to your wiki settings page ( http://localhost:3000/index.php/Spezial:Wiki_Admin ) and click on the gears-icon (labeled "Settings" or "Einstellungen"). Scroll down to "Extended Search" or "Erweitere Suche" and set the "Solr URL:" to http://172.17.0.3:8080/solr (make sure 172.17.0.3 is the ip of your solr server). Press Enter to save.

- create the database cache:
```
sudo docker exec -it wiki php /var/www/html/extensions/BlueSpiceExtensions/ExtendedSearch/maintenance/searchUpdate.php
```

- try searching for a single character to make sure the extended search is working.

Future Work
-----------
The configuration of the LocalSettings.php and database-creation could be automated.
An ansible and/or bash-script for this would be nice.
