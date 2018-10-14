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

ENV fpm_user_UID 3000
ENV fpm_user_NAME www-user
ENV fpm_group_UID 3000
ENV fpm_group_NAME www-user

RUN set -ex \
 && addgroup --system --gid ${fpm_group_UID} ${fpm_group_NAME} \
 && adduser --uid ${fpm_user_UID} --system --gid ${fpm_group_UID} ${fpm_user_NAME}
RUN sed -i \
            -e "s/^user = .*/user = ${fpm_user_NAME}/g" \
            -e "s/^group = .*/group = ${fpm_group_NAME}/g" \
            -e "s/^;listen.mode = 0660/listen.mode = 0666/g" \
            -e "s/^;listen.owner = .*/listen.owner = ${fpm_user_NAME}/g" \
            -e "s/^;listen.group = .*/listen.group = ${fpm_group_NAME}/g" \
            ${fpm_conf}

ENV PATH $PATH:/root/composer/vendor/bin
WORKDIR /var/www