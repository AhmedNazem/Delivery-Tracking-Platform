FROM php:8.3-fpm-bookworm

RUN apt-get update \
    && apt-get install -y --no-install-recommends git unzip libicu-dev libzip-dev libonig-dev libsqlite3-dev \
    && docker-php-ext-install bcmath intl mbstring pdo_mysql pdo_sqlite pcntl zip \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

WORKDIR /var/www/html

CMD ["php-fpm"]
