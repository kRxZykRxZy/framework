# Base image with PHP and Apache
FROM php:8.2-apache

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV MYSQL_ROOT_PASSWORD=secret
ENV MYSQL_DATABASE=flarum
ENV MYSQL_USER=flarum
ENV MYSQL_PASSWORD=flarum123

# Install system dependencies and MySQL server
RUN apt-get update && apt-get install -y \
    default-mysql-server \
    git \
    unzip \
    curl \
    nodejs \
    npm \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy your Flarum framework source code into the container
COPY . .

# Install PHP dependencies
RUN composer install --no-interaction --prefer-dist

# Optionally build frontend (skip if not needed)
RUN npm install && npm run build || echo "Skipping frontend build (if not configured)"

# Configure Apache to listen on port 8080
RUN sed -i 's/80/8080/g' /etc/apache2/ports.conf /etc/apache2/sites-available/000-default.conf \
    && sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf

# Expose port 8080
EXPOSE 8080

# Start MySQL and Apache when container runs
CMD service mysql start && apache2-foreground
