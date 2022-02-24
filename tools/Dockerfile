ARG FROM
FROM $FROM

ARG libs="libfreetype6 libjpeg62-turbo liblz4-tool libzip4"
ARG remoteTools="rsync wget openssh-client"
ARG fontTools="fontforge ttfautohint"
ARG editors="less nano"
#gnupg needed by phive to install other php tools
ARG tools="$editors $fontTools $remoteTools nvi iproute2 ack-grep unzip git default-mysql-client sudo make socat dnsutils iputils-ping netcat gnupg ansible python3-wheel"
ARG RUNTIME_PACKAGE_DEPS="$libs $tools msmtp bc locales"


RUN apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends $RUNTIME_PACKAGE_DEPS
RUN apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# set sendmail for php to msmtp
RUN echo "sendmail_path=/usr/bin/msmtp -t" > /usr/local/etc/php/conf.d/20-sendmail.ini
RUN echo "msmtp.log init" > /var/log/msmtp.log
RUN chmod 777 /var/log/msmtp.log

#lower security for developer environment
RUN sed -i "s/ ALL$/ NOPASSWD:ALL/" /etc/sudoers
RUN usermod -aG sudo www-data

# timezone / date
# use berlin because a lot of oxid customers are from germany
# do not rely on this setting it may be changed in fututre
RUN ln -snf /usr/share/zoneinfo/Europe/Berlin /etc/localtime && echo Europe/Berlin > /etc/timezone
RUN echo date.timezone = Europe/Berlin >> /usr/local/etc/php/conf.d/timezone.ini


COPY scripts/* /usr/local/bin/

