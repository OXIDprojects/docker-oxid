  
ARG PHP=7.1
FROM php:$PHP-apache
#libs: libjudy-dev need this for memprof
ARG libs="libfreetype6 libjpeg62-turbo liblz4-tool libjudy-dev"
ARG remoteTools="rsync wget openssh-client"
ARG fontTools="fontforge ttfautohint"
ARG editors="less nano"
ARG tools="$editors $fontTools $remoteTools python3-pip nvi iproute2 ack-grep unzip git default-mysql-client sudo npm make"
ARG RUNTIME_PACKAGE_DEPS="$libs $tools msmtp bc locales"

ARG BUILD_PACKAGE_DEPS="libcurl4-openssl-dev libjpeg-dev libpng-dev libxml2-dev"

ARG PHP_EXT_DEPS="curl json xml mbstring zip bcmath soap pdo_mysql gd mysqli"
ARG PECL_DEPS="xdebug memprof"
ARG PHP_MEMORY_LIMIT="-1"

# install dependencies and cleanup (needs to be one step, as else it will cache in the layer)
RUN apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        $RUNTIME_PACKAGE_DEPS \
        $BUILD_PACKAGE_DEPS \
    && docker-php-ext-configure gd --with-jpeg-dir=/usr/local/ \
    && docker-php-ext-install -j$(nproc) $PHP_EXT_DEPS \
    && pecl install $PECL_DEPS \
    && docker-php-ext-enable $PECL_DEPS \
    && docker-php-source delete \
    && apt-get clean \
    && apt-get autoremove -y \
    && apt-get purge -y --auto-remove $BUILD_PACKAGE_DEPS \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

#install dependencies
RUN pip3 install wheel PyMySQL setuptools boto
RUN pip3 install ansible awscli

# set sendmail for php to msmtp
RUN echo "sendmail_path=/usr/bin/msmtp -t" > /usr/local/etc/php/conf.d/20-sendmail.ini
RUN echo "msmtp.log init" > /var/log/msmtp.log
RUN chmod 777 /var/log/msmtp.log

# remove memory limit
RUN echo "memory_limit = $PHP_MEMORY_LIMIT" > /usr/local/etc/php/conf.d/memory-limit-php.ini

# prepare optional xdebug ini
#RUN echo "xdebug.remote_enable=on" >> /usr/optional_xdebug.ini && \
RUN echo "xdebug.remote_autostart=off" >> /usr/local/etc/php/conf.d/20-xdebug.ini

# add symlink to provide php also from /usr/bin
RUN ln -s /usr/local/bin/php /usr/bin/php

WORKDIR /var/www/oxideshop

# install latest composer
RUN curl --silent --show-error https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer

ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_NO_INTERACTION=1
RUN composer global require hirak/prestissimo

RUN sed -i -e "s#/var/www/html#/var/www/oxideshop/source#g" /etc/apache2/sites-enabled/000-default.conf
RUN sed -i -e "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf
RUN a2enmod rewrite

#lower security for developer environment
RUN sed -i "s/ ALL$/ NOPASSWD:ALL/" /etc/sudoers
#setting the umask systemwide does not work in debian based docker image for some reason
#e.g. will have no effectRUN sed -i -e "s/UMASK[[:space:]]\{1,\}022$/UMASK 000/" /etc/login.defs
#so setting the umask for the webserver 
RUN sed -i '2s/^/umask 000\n /' /usr/local/bin/apache2-foreground
#and for developers that using a bash
RUN echo umask 000 >> /root/.bashrc

# timezone / date
# use berlin because a lot of oxid customers are from germany
# do not rely on this setting it may be changed in fututre
RUN ln -snf /usr/share/zoneinfo/Europe/Berlin /etc/localtime && echo Europe/Berlin > /etc/timezone
RUN echo date.timezone = Europe/Berlin >> /usr/local/etc/php/conf.d/timezone.ini
