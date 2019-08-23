FROM php:7.2.10-fpm
LABEL maintainer=karasev.dmitry@gmail.com

ENV zz_docker_conf /usr/local/etc/php-fpm.d/zz-docker.conf
ENV PHP_INI_SCAN_DIR "/usr/local/etc/php/custom.d:/usr/local/etc/php/conf.d"
ENV ENV TZ=Europe/Moscow
ENV LISTEN_SOCKET ''
ENV SOCKET_PATH /var/run/php-fpm.sock
# versions of extensions
ENV EXT_APCU_VERSION=5.1.17
ENV EXT_REDIS_VERSION=4.3.0
ENV EXT_IGBINARY_VERSION=3.0.1
ENV XDEBUG_VERSION 2.6.1
ENV EXT_MONGODB_VERSION=1.5.2

# Install PHP extensions and PECL modules.
RUN buildDeps=" \
        default-libmysqlclient-dev \
        libbz2-dev \
        libsasl2-dev \
    " \
    runtimeDeps=" \
        curl \
        git \
        apt-utils \
        libfreetype6-dev \
        libicu-dev \
        libjpeg-dev \
        libldap2-dev \
        libpng-dev \
        libpq-dev \
        zip \
        libzip-dev \
        libxml2-dev \
        libsnmp-dev \
        snmp-mibs-downloader \
        procps \
        htop \
        unzip \
        tzdata \
        iputils-ping \
        dnsutils \
    " \
    && sed -i /etc/apt/sources.list -e 's/$/ contrib non-free'/ \
    && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y $buildDeps $runtimeDeps \
    && docker-php-source extract \
    && docker-php-ext-install -j$(nproc) \
            bcmath \
            bz2 \
            calendar \
            iconv \
            intl \
            mbstring \
            mysqli \
            opcache \
            pdo_mysql \
            pdo_pgsql \
            pgsql \
            soap \
            zip \
            exif \
            sockets \
            pcntl \
            snmp \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    #ext-ldap
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install -j$(nproc) ldap \
    # ext-igbinary
    && mkdir -p /usr/src/php/ext/igbinary \
    &&  curl -fsSL https://github.com/igbinary/igbinary/archive/$EXT_IGBINARY_VERSION.tar.gz | tar xvz -C /usr/src/php/ext/igbinary --strip 1 \
    && docker-php-ext-install igbinary \
    # ext-redis
    && mkdir -p /usr/src/php/ext/redis \
    && curl -fsSL https://github.com/phpredis/phpredis/archive/$EXT_REDIS_VERSION.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
    && docker-php-ext-configure redis --enable-redis-igbinary \
    && docker-php-ext-install redis \
    # ext-apcu
    && mkdir -p /usr/src/php/ext/apcu \
    && curl -fsSL https://github.com/krakjoe/apcu/archive/v$EXT_APCU_VERSION.tar.gz | tar xvz -C /usr/src/php/ext/apcu --strip 1 \
    && docker-php-ext-install apcu \
    #ext-mongodb
    && git clone --branch $EXT_MONGODB_VERSION --depth 1 https://github.com/mongodb/mongo-php-driver.git /usr/src/php/ext/mongodb \
    && cd /usr/src/php/ext/mongodb && git submodule update --init \
    && docker-php-ext-install mongodb \
    # clearing
    && docker-php-source delete \
    && apt-get purge -y --auto-remove $buildDeps \
    && rm -r /var/lib/apt/lists/* 
# install xdebug
RUN if [ "${http_proxy}" != "" ]; then \
        pear config-set http_proxy ${http_proxy} \
    ;fi \
    && pecl install xdebug-${XDEBUG_VERSION} \
    && docker-php-ext-enable xdebug 

# create directory for customer's .ini files
RUN mkdir -p /usr/local/etc/php/custom.d

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && ln -s $(composer config --global home) /root/composer
ENV PATH $PATH:/root/composer/vendor/bin

WORKDIR /var/www

# set custom entrypoint
COPY ./custom-docker-entrypoint /usr/local/bin/
RUN chmod u+x /usr/local/bin/custom-docker-entrypoint

ENTRYPOINT ["custom-docker-entrypoint"]
CMD ["php-fpm"]