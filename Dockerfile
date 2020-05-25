FROM maximus905/php-fpm:latest
LABEL maintainer=karasev.dmitry@gmail.com

ENV GIT_USER "Joe"
ENV GIT_EMAIL "joe@mail.joe"

# Install Symfony
RUN  wget https://get.symfony.com/cli/installer -O - | bash \
    && mv /root/.symfony/bin/symfony /usr/local/bin/symfony

WORKDIR /var/www

# set custom entrypoint
COPY ./symfony-docker-entrypoint /usr/local/bin/
RUN chmod u+x /usr/local/bin/symfony-docker-entrypoint

ENTRYPOINT ["symfony-docker-entrypoint"]
CMD ["php-fpm"]