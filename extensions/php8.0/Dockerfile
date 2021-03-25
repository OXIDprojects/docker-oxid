ARG PHP=8.0
ARG SERVER=apache
FROM php:$PHP-apache

#libs:
#libzip4 need this to enable extensions
ARG libs="libfreetype6 libjpeg62-turbo liblz4-tool libzip4 libjudydebian1"

#libjudy-dev need this for memprof
#libzip4 need this to enable extensions
ARG BUILD_PACKAGE_DEPS="libzip-dev libcurl4-openssl-dev libjpeg-dev libpng-dev libxml2-dev libonig-dev libssl-dev libjudy-dev"
#without core modules like json,curl because they are already part of php 8 see https://github.com/docker-library/php/issues/102 and https://github.com/docker-library/php/issues/1049
ARG PHP_EXT_DEPS="xml zip bcmath soap pdo_mysql gd mysqli exif opcache"

#php8 compatible xdebug is xdebug-3.0
ARG PECL_DEPS_INSTALL="memprof xdebug"
ARG PHP_MEMORY_LIMIT="-1"

RUN apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends $BUILD_PACKAGE_DEPS $libs \
    && docker-php-source extract \
    && docker-php-ext-configure zip \
    && docker-php-ext-configure gd --with-jpeg=/usr/local/ \
    && docker-php-ext-install -j$(nproc) $PHP_EXT_DEPS \
    && pecl install $PECL_DEPS_INSTALL \
    && docker-php-source delete \
    && apt-get purge -y --auto-remove $BUILD_PACKAGE_DEPS

ARG PECL_DEPS_ENABLE="memprof xdebug"
RUN docker-php-ext-enable $PECL_DEPS_ENABLE
RUN ln -s /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini

# remove memory limit
RUN echo "memory_limit = $PHP_MEMORY_LIMIT" > /usr/local/etc/php/conf.d/memory-limit-php.ini

# add symlink to provide php also from /usr/bin
RUN ln -s /usr/local/bin/php /usr/bin/php

WORKDIR /var/www/oxideshop

RUN sed -i -e "s#/var/www/html#/var/www/oxideshop/source#g" /etc/apache2/sites-enabled/000-default.conf
RUN sed -i -e "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf
RUN a2enmod rewrite

# setting the umask to 000 to allow to open files created by docker container
#systemwide does not work in debian based docker image for some reason
#e.g. will have no effectRUN sed -i -e "s/UMASK[[:space:]]\{1,\}022$/UMASK 000/" /etc/login.defs
#so setting the umask for the webserver 
RUN sed -i '2s/^/umask 000\n /' /usr/local/bin/apache2-foreground
#and for developers that using a bash
RUN echo umask 000 >> /root/.bashrc


