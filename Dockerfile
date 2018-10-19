FROM php:7.2.10-fpm
MAINTAINER dev@chialab.it

ENV fpm_conf /usr/local/etc/php-fpm.d/www.conf

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
    && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y $buildDeps $runtimeDeps \
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

# Install Composer.
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && ln -s $(composer config --global home) /root/composer

# install tools
RUN apt-get update && apt-get install -y procps htop \
    && apt-get purge -y --auto-remove $buildDeps \
    && rm -r /var/lib/apt/lists/*

ARG fpm_listen=127.0.0.1:900
ARG user_UID=3000
ARG user_NAME=www-user
ARG group_UID=3000
ARG group_NAME=www-user

RUN set -ex \
 && addgroup --system --gid $group_UID $group_NAME \
 && adduser --uid $user_UID --system --gid $group_UID $user_NAME
RUN sed -i \
            -e "s/^user = .*/user = $user_NAME/g" \
            -e "s/^group = .*/group = $group_NAME/g" \
            -e "s/^;listen.mode = 0660/listen.mode = 0666/g" \
            -e "s/^;listen.owner = .*/listen.owner = $user_NAME/g" \
            -e "s/^;listen.group = .*/listen.group = $group_NAME/g" \
            -e "s/^listen = 127.0.0.1:9000/listen = $fpm_listen/g" \
            $fpm_conf

ENV PATH $PATH:/root/composer/vendor/bin
WORKDIR /var/www