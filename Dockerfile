## Set our base image ##
FROM php:8-apache

## Install Required Packages ##
RUN apt-get update && apt-get install -y --no-install-recommends wget nano vim git tar gnupg lsb-release automake libtool autoconf

## Install gpg keys ##
RUN mkdir /etc/apt/keyrings
RUN wget -qO - https://modsecurity.digitalwave.hu/archive.key | gpg --dearmor | tee /etc/apt/keyrings/modsecurity.gpg
RUN wget -qO - https://deb.nodesource.com/gpgkey/nodesource.gpg.key | gpg --dearmor | tee /etc/apt/keyrings/nodesource

## Setup Repos and apt pinning ##
RUN echo "deb [signed-by=/etc/apt/keyrings/modsecurity.gpg] http://modsecurity.digitalwave.hu/debian/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/dwmodsec.list
RUN echo "deb [signed-by=/etc/apt/keyrings/modsecurity.gpg] http://modsecurity.digitalwave.hu/debian/ $(lsb_release -sc)-backports main" >> /etc/apt/sources.list.d/dwmodsec.list
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource] https://deb.nodesource.com/node_18.x bullseye main" > /etc/apt/sources.list.d/nodesource.list
COPY ./configs/99modsecurity /etc/apt/preferences.d/99modsecurity

## Install PHP Extension Installer ##
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions

## Install Packages and Extensions ##
RUN apt-get update && apt-get install -y --no-install-recommends nodejs libapache2-mod-security2
RUN install-php-extensions bcmath exif gd gettext imagick intl mysqli opcache pdo_mysql redis zip

## Symlink and update for Node ##
RUN ln -s /usr/bin/node /usr/local/bin/node
RUN npm install npm@latest -g

## Setup Modsecurity ##
# https://www.linuxcapable.com/how-to-install-modsecurity-with-apache-on-ubuntu-linux
# https://modsecurity.digitalwave.hu
# https://coreruleset.org/docs/deployment/install
RUN cp /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf
RUN sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /etc/modsecurity/modsecurity.conf
RUN sed -i 's/SecAuditLogParts ABDEFHIJZ/SecAuditLogParts ABCEFHJKZ/' /etc/modsecurity/modsecurity.conf

## Install OWASP Core Rule Set ##
RUN git clone https://github.com/coreruleset/coreruleset /etc/apache2/modsecurity.d/coreruleset
RUN cp /etc/apache2/modsecurity.d/coreruleset/crs-setup.conf.example /etc/apache2/modsecurity.d/coreruleset/crs-setup.conf
COPY configs/modsec_rules.conf /etc/apache2/conf-enabled

## MaxMind DB ##
#RUN git clone https://github.com/maxmind/mod_maxminddb /root/mod_maxminddb
#RUN cd /root/mod_maxminddb && ./bootstrap && ./configure && make install

## Enable Modules ##
RUN a2enmod rewrite security2 headers

## COPY Composer ##
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

## Cleanup ##
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*
