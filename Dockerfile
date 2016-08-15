FROM ubuntu:14.04

MAINTAINER Di Zhang <zhangdi_me@163.com>

ADD ./sources.list /etc/apt/sources.list

RUN LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php && \
    apt-get update && \
    apt-get upgrade -y

RUN apt-get install -y python-software-properties software-properties-common language-pack-en-base \
      ntp build-essential supervisor wget

RUN apt-get install -y apache2 apache2-utils

RUN apt-get install -y php7.0 php7.0-cli php7.0-readline php7.0-common php7.0-curl php7.0-dev php7.0-gd php7.0-mbstring \
      php7.0-geoip php7.0-imagick php7.0-intl php7.0-json php7.0-mcrypt php7.0-mysql php7.0-sqlite php7.0-bcmath php7.0-zip

RUN sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php/7.0/apache2/php.ini

RUN wget https://github.com/swoole/swoole-src/archive/1.8.7-stable.tar.gz && tar xzvf 1.8.7-stable.tar.gz && cd swoole-src-1.8.7-stable/ && \
    phpize && \
    ./configure && \
    make && make install && echo -e "; configuration for swoole module\n; priority=20\nextension=swoole.so" > /etc/php/7.0/mods-available/swoole.ini && phpenmod swoole

RUN wget https://github.com/laruence/yaconf/archive/yaconf-1.0.2.tar.gz && tar xzvf yaconf-1.0.2.tar.gz && cd yaconf-yaconf-1.0.2/ && \
    phpize && \
    ./configure && \
    make && make install && echo -e "; configuration for Yaconf module\n; priority=20\nextension=yaconf.so\nyaconf.directory=/tmp/yaconf" > /etc/php/7.0/mods-available/yaconf.ini && phpenmod yaconf

RUN a2enmod rewrite

RUN mkdir -p /var/run/sshd /var/log/supervisor /var/lock/apache2 /var/run/apache2

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ADD 000-default.conf /etc/apache2/sites-available/000-default.conf

RUN apt-get autoclean

WORKDIR /var/www/html

EXPOSE 80
CMD ["/usr/bin/supervisord"]