FROM php:7.2-apache
COPY ./install-php-extensions /usr/local/bin/
RUN a2enmod rewrite && \
    install-php-extensions gd intl soap bcmath xsl pdo_mysql zip sockets