FROM php:8-apache

# Copy source code
COPY ./ /var/www/html/

RUN apt-get update  \
    && apt-get install -y git unzip

# Install dependencies
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Allow composer to be run as root
ENV COMPOSER_ALLOW_SUPERUSER 1

# Install dependencies
RUN composer install

# Create the database
RUN php bin/console doctrine:database:create --no-interaction

# Run migrations
RUN php bin/console doctrine:migrations:migrate --no-interaction

# Load fixtures
RUN php bin/console doctrine:fixtures:load --no-interaction

# Clear cache
RUN APP_ENV=prod APP_DEBUG=0 php bin/console cache:clear

# Set document root to public folder
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Expose port 80
EXPOSE 80
