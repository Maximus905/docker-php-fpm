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
* PHP modules(php -m output):
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