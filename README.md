# PHP-FPM image
### based on php:7.2-fpm image.
### appended packages and extensions:
* tools like ps, htop, zip, unzip
* x-debug for debugging
### custom settings:
* php.ini is made based on template files:
* php.ini-development - for development mode
* php.ini-production - for production mode
* default choice is production mode, but you can change it by setting ENV variable DEVELOPMENT_MODE to any non empty value. For example:
```
  docker container run --rm -d -e DEVELOPMENT_MODE=yes maximus905/php-fpm
```
#### how to put custom .ini files:
* custom .ini files are scanned in folder "/usr/local/etc/php/custom.d",
so php.ini file and folder with all custom .ini files should be mounted in docker-compose file like this:
```
php:
    image: maximus905/php-fpm
    volumes:
      - ./www:/var/www
      - ./conf/php/php.ini:/usr/local/etc/php/php.ini
      - ./conf/php/custom.d:/usr/local/etc/php/custom.d
```
### PHP-FPM listener configuration:
##### By default php-fpm listen TCP socket (port 9000).
For changing listener to Unix socket pass env variable LISTEN_SOCKET=yes
``` 
docker container run --rm -d -e LISTEN_SOCKET=yes maximus905/php-fpm
```
In this case will be created system user and socket file:
* ENV SOCKET_PATH /var/run/php-fpm.sock
* user and group for socket will be set as: www-data (it's a default user and group for socket)

Don't forget to set properly web server configuration to use unix socket and mount socket like this:
```
services:
  nginx:
    image: maximus905/nginx
    ports:
      - "8082:80"
    volumes:
      - ./www:/var/www
      - ./conf/nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./conf/nginx/sites-enabled:/etc/nginx/conf.d
      - phpsocket:/var/run
  php:
    image: maximus905/php-fpm
    environment:
      - LISTEN_SOCKET=yes
      - DEVELOPMENT_MODE=yes
    working_dir: /var/www/my_site.ru
    volumes:
      - ./www:/var/www
      - ./conf/php/custom.d:/usr/local/etc/php/custom.d
      - phpsocket:/var/run
volumes:
  phpsocket:
```

### Timezone
Default Timezone in container - ENV TZ=Europe/Moscow
If you want to change - set env variable TZ 
``` 
docker container run --rm -d -e TZ=UTC maximus905/php-fpm
```
### PHP modules(php -m output):
``` php
[PHP Modules]
apcu
bcmath
bz2
calendar
Core
ctype
curl
date
dom
exif
fileinfo
filter
ftp
gd
hash
iconv
igbinary
intl
json
ldap
libxml
mbstring
mongodb
mysqli
mysqlnd
openssl
pcntl
pcre
PDO
pdo_mysql
pdo_pgsql
pdo_sqlite
pgsql
Phar
posix
readline
redis
Reflection
session
SimpleXML
snmp
soap
sockets
sodium
SPL
sqlite3
ssh2
standard
tokenizer
xdebug
xml
xmlreader
xmlwriter
Zend OPcache
zip
zlib

[Zend Modules]
Xdebug
Zend OPcache      
```
