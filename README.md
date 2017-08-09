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
Configure the src/LocalSettings.php. You like to change the $wgDBpassword to your MySQL-Password, $wgSecretKey to a 64-diget hex value and $wgUpgradeKey to a 16-diget hex value as well as the MySQL-Server ip for $wgDBserver. Take a look at the localconfig.sh file that sets these parameters automatically.

You might also want to change the $wgServer, $wgSitename, $wgEmergencyContact and $wgPasswordSender, $language. 

Note that I default to german (de)!

Installation
------------
Note that I use two different MySQL-Passwords here: MYSQL_ROOT_PASSWORD and MYSQL_USER_PASSWORD. You maybe want to change those to something more useful.

- install docker for your system (e.g. [Docker CE for Ubuntu](https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/))
- run mysql 
```
sudo docker run --name mysql-mediawiki -e MYSQL_ROOT_PASSWORD=MYSQL_ROOT_PASSWORD -d mysql/mysql-server:5.7
```
- run solr
```
sudo docker run --name bluespice-solr -d bluespice/solr:REL1_27
```
- configure the src/LocalSettings.php (or run `sh localconfig.sh MYSQL_USER_PASSWORD` to change parts of the file automatically)
- create the docker container
```
sudo docker build -t mediawiki .
```
- start the docker container (note that I forward to port 3000 because I use an nginx on the host machine that also provides other services)
```
sudo docker run --name wiki -p 3000:80 --link mysql-mediawiki:mysql --link bluespice-solr:solr -d mediawiki
```
- this will fail becasue the Machine does not have access rights on the mysql-server, but we needed to start it first to get its ip:
```
WIKI_IP=`sudo docker inspect wiki | grep -Po '(?<="IPAddress": ")\d+\.\d+\.\d+\.\d+' | head -n1`
echo "Mediawiki Server ip:" $WIKI_IP
```
now we grant access rights to a new user for this ip on the mysql-server and start the wiki like this (you might want to change the username and PASSWORD to something else):
```
sudo docker exec -it mysql-mediawiki mysql -u root -pMYSQL_ROOT_PASSWORD -e "GRANT ALL ON mediawiki.* TO wikiuser@172.17.0.4 IDENTIFIED BY 'MYSQL_USER_PASSWORD'";
sudo docker start wiki
```


Troubleshooting
---------------
Make sure you setup the MySQL-Server first and verify that its ip is 172.17.0.2. If not change that in the LocalSettings.php .

Future Work
-----------
The configuration of the LocalSettings.php could be much nicer integrated with docker and the mysql-user generation could be automated.
An ansible and/or bash-script for this would be nice.
