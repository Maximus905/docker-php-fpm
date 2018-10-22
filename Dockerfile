FROM php:7.2.10-fpm
MAINTAINER karasev.dmitry@gmail.com

ENV fpm_conf /usr/local/etc/php-fpm.d/www.conf
ENV zz_docker_conf /usr/local/etc/php-fpm.d/zz-docker.conf
ENV PHP_INI_SCAN_DIR "/usr/local/etc/php/custom.d:/usr/local/etc/php/conf.d"

# Install PHP extensions and PECL modules.
RUN buildDeps=" \
        default-libmysqlclient-dev \
        libbz2-dev \
        libmemcached-dev \
        libsasl2-dev \
    " \
    runtimeDeps=" \
        curl \
        git \
        libfreetype6-dev \
        libicu-dev \
        libjpeg-dev \
        libldap2-dev \
        libmemcachedutil2 \
        libpng-dev \
        libpq-dev \
        libxml2-dev \
    " \
    && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y $buildDeps $runtimeDeps \
    && docker-php-ext-install -j$(nproc) bcmath bz2 calendar iconv intl mbstring mysqli opcache pdo_mysql pdo_pgsql pgsql soap zip \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install -j$(nproc) ldap \
    && docker-php-ext-install -j$(nproc) exif \
    && docker-php-ext-install -j$(nproc) sockets \
    && pecl install memcached redis \
    && docker-php-ext-enable memcached.so redis.so \
    && apt-get purge -y --auto-remove $buildDeps \
    && rm -r /var/lib/apt/lists/* 

# install xdebug
RUN pecl install xdebug-2.6.1 \
    && docker-php-ext-enable xdebug 

# create directory for customer's .ini files
RUN mkdir -p /usr/local/etc/php/custom.d

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && ln -s $(composer config --global home) /root/composer

# install tools
RUN apt-get update && apt-get install --no-install-recommends -y procps htop zip unzip \
    && apt-get purge -y --auto-remove \
    && rm -r /var/lib/apt/lists/*

ENV PATH $PATH:/root/composer/vendor/bin
WORKDIR /var/www