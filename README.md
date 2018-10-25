# PHP-FPM image
### based on php:7.2-fpm image.
### appended packages and extensions:
* tools like ps, htop, zip, unzip
* x-debug for debugging
### custom settings:
* php.ini isn't present in this image
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
For changing listener to Unix socket pass set env variable LISTEN_SOCKET='yes'
``` 
docker container run --rm -d -e LISTEN_SOCKET=yes maximus905/php-fpm
```
In this case will be created system user and socket file:
* ENV SOCKET_PATH /var/run/php-fpm.sock
* ENV SOCKET_USER_UID 3000
* ENV SOCKET_USER_NAME www-user
* ENV SOCKET_GROUP_UID 3000
* ENV SOCKET_GROUP_NAME www-user 

Don't forget to set properly web server configuration to use unix socket 

### Timezone
Default Timezone in container - ENV TZ=Europe/Moscow
If you want to change - set env variable TZ 
``` 
docker container run --rm -d -e TZ=UTC maximus905/php-fpm
```
### PHP modules(php -m output):
``` php
[PHP Modules]          
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
intl                   
json                   
ldap                   
libxml                 
mbstring               
memcached              
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
soap                   
sockets                
sodium                 
SPL                    
sqlite3                
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