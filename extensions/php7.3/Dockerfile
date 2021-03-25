ARG PHP=7.4
ARG SERVER=apache
FROM php:$PHP-apache

#libs:
#libzip4 need this to enable extensions
ARG libs="libfreetype6 libjpeg62-turbo liblz4-tool libzip4 libjudydebian1"

#libjudy-dev need this for memprof
ARG BUILD_PACKAGE_DEPS="libzip-dev libcurl4-openssl-dev libjpeg-dev libpng-dev libxml2-dev libonig-dev libssl-dev libjudy-dev"

RUN apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends $BUILD_PACKAGE_DEPS $libs

RUN docker-php-source extract
RUN docker-php-ext-configure zip
RUN docker-php-ext-configure gd --with-jpeg-dir=/usr/local/

#curl json mbstring only needed for php < 8
ARG PHP_EXT_DEPS="curl json xml mbstring zip bcmath soap pdo_mysql gd mysqli exif opcache"

RUN docker-php-ext-install -j$(nproc) $PHP_EXT_DEPS

#php7.4 compatible xdebug is xdebug-2.8
ARG PECL_DEPS_INSTALL="memprof xdebug-2.8.1"
RUN pecl install $PECL_DEPS_INSTALL

RUN docker-php-source delete
RUN apt-get purge -y --auto-remove $BUILD_PACKAGE_DEPS

############################## END OF PHP BUILD JOB #######################

RUN ln -s /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini
ARG PHP_MEMORY_LIMIT="-1"

ARG PECL_DEPS_ENABLE="memprof xdebug"
RUN docker-php-ext-enable $PECL_DEPS_ENABLE

# remove memory limit
RUN echo "memory_limit = $PHP_MEMORY_LIMIT" > /usr/local/etc/php/conf.d/memory-limit-php.ini

# add symlink to provide php also from /usr/bin
RUN ln -s /usr/local/bin/php /usr/bin/php

WORKDIR /var/www/oxideshop

RUN sed -i -e "s#/var/www/html#/var/www/oxideshop/source#g" /etc/apache2/sites-enabled/000-default.conf
RUN sed -i -e "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf
RUN a2enmod rewrite

#setting the umask systemwide does not work in debian based docker image for some reason
#e.g. will have no effectRUN sed -i -e "s/UMASK[[:space:]]\{1,\}022$/UMASK 000/" /etc/login.defs
#so setting the umask for the webserver 
RUN sed -i '2s/^/umask 000\n /' /usr/local/bin/apache2-foreground
#and for developers that using a bash
RUN echo umask 000 >> /root/.bashrc


