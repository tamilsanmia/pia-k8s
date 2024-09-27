# Use the official Ubuntu base image
FROM ubuntu:jammy

# Set environment variables
ENV TZ=Asia/Kolkata \
    DEBIAN_FRONTEND=noninteractive 

# Define PHP and Node.js versions
ENV PHP_VERSION=8.2 \
    NODE_VERSION=20

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
    sudo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Add PPA repositories for Apache2 and PHP
RUN add-apt-repository ppa:ondrej/apache2 && \
    add-apt-repository ppa:ondrej/php && \
    apt-get update

# Install Apache2
RUN apt-get install -y apache2

# Install PHP and necessary extensions
RUN apt-get install -y \
    php${PHP_VERSION} \
    libapache2-mod-php${PHP_VERSION} \
    php${PHP_VERSION}-mysql \
    php${PHP_VERSION}-cli \
    php${PHP_VERSION}-common \
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
    php${PHP_VERSION}-memcached 

# Update PHP configuration for all configurations
RUN for config in cli apache2; do \
        sed -i -e 's/^file_uploads = .*/file_uploads = On/' \
               -e 's/^allow_url_fopen = .*/allow_url_fopen = On/' \
               -e 's/^short_open_tag = .*/short_open_tag = On/' \
               -e 's/^memory_limit = .*/memory_limit = 256M/' \
               -e 's/^;cgi.fix_pathinfo=1.*/cgi.fix_pathinfo = 0/' \
               -e 's/^upload_max_filesize = .*/upload_max_filesize = 100M/' \
               -e 's/^post_max_size = .*/post_max_size = 100M/' \
               -e 's/^max_execution_time = .*/max_execution_time = 360/' \
            /etc/php/${PHP_VERSION}/$config/php.ini; \
    done

# Download and install ionCube Loader
RUN extension_dir=$(php -i | grep ^extension_dir | awk '{print $3}') && \
    curl -fsSL https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz -o ioncube_loaders.tar.gz && \
    tar -xzf ioncube_loaders.tar.gz && \
    mv ioncube/ioncube_loader_lin_${PHP_VERSION}.so "$extension_dir" && \
    for config in apache2 cli; do \
        sed -i "2 a zend_extension=${extension_dir}/ioncube_loader_lin_${PHP_VERSION}.so" /etc/php/${PHP_VERSION}/$config/php.ini; \
    done && \
    rm -rf ioncube_loaders.tar.gz ioncube

# Install wkhtmltopdf
RUN apt-get update && \
    apt-get install -y wkhtmltopdf

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - && \
    apt-get install -y nodejs

# Create a 'faveo' user and group
RUN groupadd -r faveo && \
    useradd -r -m -s /bin/bash -g faveo faveo
RUN usermod -a -G sudo faveo

# Configure sudo to not require a password for 'faveo'
RUN echo "faveo ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/faveo

# Change the Apache process owner to 'faveo' user and group
RUN sed -i 's/^User .*/User faveo/' /etc/apache2/apache2.conf && \
    sed -i 's/^Group .*/Group faveo/' /etc/apache2/apache2.conf

# Update Apache ports.conf to listen on port 8080
RUN sed -i 's/^Listen 80/Listen 8080/' /etc/apache2/ports.conf

# Grant Apache permission to bind to port 80 without root privileges
RUN setcap 'cap_net_bind_service=+ep' /usr/sbin/apache2

# Create the /var/www/html/public directory if it doesn't exist
RUN mkdir -p /var/www/html/public

# Create an index.php file with PHP info
RUN echo "<?php phpinfo(); ?>" > /var/www/html/public/index.php

# Set permissions for Apache directories
RUN chown -R faveo:faveo /etc/apache2 /var/www /var/log/apache2 /var/run/apache2/ /usr/sbin/apache2 /usr/bin/php /usr/sbin/apachectl

# Set the working directory
WORKDIR /var/www/html

# Add ServerName directive to Apache configuration
RUN echo "ServerName 127.0.0.1" >> /etc/apache2/apache2.conf

# Copy Apache virtual host configuration
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf

# Copy the start-services script into the container
COPY start-services.sh /usr/local/bin/start-services.sh

# Make the script executable
RUN chmod +x /usr/local/bin/start-services.sh

# Change the ownership of the script to the 'faveo' user
RUN chown faveo:faveo /usr/local/bin/start-services.sh

# Enable necessary Apache modules and configurations
RUN a2enmod proxy_fcgi setenvif rewrite headers

# Expose necessary ports
EXPOSE 8080

USER faveo

# Set the entry point or command to the switch script
CMD ["/usr/local/bin/start-services.sh"]