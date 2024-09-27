# Use the official Ubuntu base image
FROM ubuntu:jammy

# Set environment variables
ENV TZ=Asia/Kolkata \
    DEBIAN_FRONTEND=noninteractive 

# Define PHP versions
ENV PHP_VERSION=8.2

# Update package lists and install initial packages
RUN apt-get update && \
    apt-get install -y \
    tzdata \
    software-properties-common \
    ca-certificates \
    git \
    wget \
    curl \
    unzip \
    nano \
    zip \
    apt-utils \
    supervisor && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Add PPA repositories for PHP
RUN add-apt-repository ppa:ondrej/php && \
    apt-get update

# Install PHP and necessary extensions
RUN apt-get install -y \
    php${PHP_VERSION} \
    php${PHP_VERSION}-mysql \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-common \
    php${PHP_VERSION}-fpm \
    php${PHP_VERSION}-soap \
    php${PHP_VERSION}-gd \
    php${PHP_VERSION}-opcache \
    php${PHP_VERSION}-mbstring \
    php${PHP_VERSION}-zip \
    php${PHP_VERSION}-bcmath \
    php${PHP_VERSION}-intl \
    php${PHP_VERSION}-xml \
    php${PHP_VERSION}-curl \
    php${PHP_VERSION}-imap \
    php${PHP_VERSION}-ldap \
    php${PHP_VERSION}-gmp \
    php${PHP_VERSION}-redis \
    php${PHP_VERSION}-memcache

# Download and install ionCube Loader
RUN extension_dir=$(php -i | grep ^extension_dir | awk '{print $3}') && \
    curl -fsSL https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz -o ioncube_loaders.tar.gz && \
    tar -xzf ioncube_loaders.tar.gz && \
    mv ioncube/ioncube_loader_lin_${PHP_VERSION}.so "$extension_dir" && \
    for config in cli fpm; do \
        sed -i "2 a zend_extension=${extension_dir}/ioncube_loader_lin_${PHP_VERSION}.so" /etc/php/${PHP_VERSION}/$config/php.ini; \
    done && \
    rm -rf ioncube_loaders.tar.gz ioncube

# Copy Supervisor configuration file
COPY faveo-worker.conf /etc/supervisor/conf.d/faveo-worker.conf
RUN mkdir -p /var/www/html/storage/logs && \
    chown -R www-data:www-data /var/www/html/storage/logs && \
    chmod -R 755 /var/www/html/storage/logs


# Set the working directory
WORKDIR /var/www/html

# Set CMD to Supervisor service
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]