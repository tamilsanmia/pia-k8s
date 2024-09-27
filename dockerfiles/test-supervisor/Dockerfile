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
    sudo \
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

# Create a 'faveo' user and group
RUN groupadd -r faveo && \
    useradd -r -m -s /bin/bash -g faveo faveo && \
    usermod -a -G sudo faveo

# Configure sudo to not require a password for 'faveo'
RUN echo "faveo ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/faveo && \
    chmod 0440 /etc/sudoers.d/faveo

# Copy Supervisor configuration file
COPY faveo-worker.conf /etc/supervisor/conf.d/faveo-worker.conf
# Create necessary directories and log file
RUN mkdir -p /var/www/html/storage/logs && \
    mkdir -p /var/log/supervisor && \
    touch /var/log/supervisord.log

# Change ownership of the specified directories and files
RUN sudo chown -R faveo:faveo \
    /etc/supervisor/ \
    /usr/bin/python3 \
    /usr/lib/python3 \
    /usr/bin/supervisord \
    /usr/bin/php8.2 \
    /var/log/supervisor \
    /usr/bin/supervisord \
    /usr/bin/php \
    /var/www/html \
    /var/run \
    /var/log/supervisord.log


RUN sudo service supervisor start
RUN chown faveo:faveo /var/run/supervisor.sock
RUN chmod 770 /var/run/supervisor.sock

# Copy the start-services script into the container
COPY start-services.sh /usr/local/bin/start-services.sh

# Make the script executable
RUN chmod +x /usr/local/bin/start-services.sh

# Change the ownership of the script to the 'faveo' user
RUN chown faveo:faveo /usr/local/bin/start-services.sh
# Set the working directory
WORKDIR /var/www/html

# Set CMD to Supervisor service
CMD ["/usr/local/bin/start-services.sh"]