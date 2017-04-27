FROM php:7-apache
MAINTAINER Wesley Elfring <hi@wesleyelfring.nl>

# Install PHP extensions
RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
      
      # Install libs for building PHP exts
      libicu-dev \
      libpq-dev \
      libmcrypt-dev \
      libfreetype6-dev \
      libjpeg62-turbo-dev \
      libmcrypt-dev \
      libpng12-dev \
      unzip \
    && rm -r /var/lib/apt/lists/* \
    
    # Setup PHP exts
    && docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd \
    && docker-php-ext-install \
      intl \
      mbstring \
      mcrypt \
      pcntl \
      pdo_mysql \
      pdo_pgsql \
      pgsql \
      zip \
      opcache \
      tokenizer \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && pecl install redis \
    && pecl install xdebug \
    && docker-php-ext-enable redis tokenizer \
    
    # Cleanup
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add apache config for Laravel
COPY site.conf /etc/apache2/sites-available/site.conf
RUN a2dissite 000-default.conf && a2ensite site.conf && a2enmod rewrite

# Change uid and gid of apache to docker user uid/gid
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data
