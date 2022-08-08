ARG FROM
FROM $FROM

# install composer
RUN curl -LO https://getcomposer.org/download/2.0.12/composer.phar && \
    chmod +x composer.phar && \
    mv composer.phar /usr/local/bin/composer

# install phive
RUN curl -LO https://phar.io/releases/phive.phar && \
    chmod +x phive.phar && \
    mv phive.phar /usr/local/bin/phive

ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_NO_INTERACTION=1
# removed prestissimo because we can user composer 2
# RUN composer global require hirak/prestissimo

