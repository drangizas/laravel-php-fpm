# syntax=docker/dockerfile:1

FROM php:8.5-fpm AS extensions-builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    unzip \
    ca-certificates \
    libpq-dev \
    libonig-dev \
    libssl-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    libicu-dev \
    libzip-dev \
    && docker-php-ext-install -j"$(nproc)" \
    pdo_pgsql \
    pgsql \
    intl \
    zip \
    bcmath \
    soap \
    curl \
    pcntl \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && curl -fsSL https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Runtime image: Debian slim with PHP copied out of the official image, so
# none of the official image's build toolchain ($PHPIZE_DEPS: gcc, perl,
# python, headers - ~390 MB) ends up in production. Extensions are compiled
# in extensions-builder above; only their shared-library deps are installed.
FROM debian:trixie-slim AS base

LABEL org.opencontainers.image.title="php-fpm base for laravel"
LABEL org.opencontainers.image.description="Reusable php-fpm base image for laravel deployments; includes php extensions (pgsql, intl, zip, bcmath, soap, pcntl, redis), composer and app runtime tools."

ENV PHP_INI_DIR=/usr/local/etc/php

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    unzip \
    # shared libraries PHP and the compiled extensions link against
    libargon2-1 \
    libcurl4t64 \
    libicu76 \
    libonig5 \
    libpq5 \
    libreadline8t64 \
    libsodium23 \
    libsqlite3-0 \
    libssl3t64 \
    libxml2 \
    libzip5 \
    zlib1g \
    # app runtime tools
    libfcgi-bin \
    procps \
    nginx \
    libnginx-mod-http-headers-more-filter \
    supervisor \
    gosu \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=extensions-builder /usr/local/bin/ /usr/local/bin/
COPY --from=extensions-builder /usr/local/sbin/php-fpm /usr/local/sbin/php-fpm
COPY --from=extensions-builder /usr/local/lib/php/ /usr/local/lib/php/
COPY --from=extensions-builder /usr/local/etc/ /usr/local/etc/

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
    && php -m > /dev/null

WORKDIR /var/www

ENTRYPOINT ["docker-php-entrypoint"]
STOPSIGNAL SIGQUIT
EXPOSE 9000
CMD ["php-fpm"]
