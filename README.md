# laravel-php-fpm

Slim php-fpm base image for Laravel apps: PHP 8.5 on `debian:trixie-slim` with
pdo_mysql, pdo_pgsql, pgsql, intl, zip, bcmath, soap, curl, pcntl, gd (freetype, jpeg,
webp), exif, redis, Composer, nginx, supervisor, gosu and poppler-utils
(pdfinfo, pdftotext).

Pushing a `Dockerfile` change to `main` (or running the workflow manually)
publishes:

- `ghcr.io/drangizas/laravel-php-fpm:8.5`
- `ghcr.io/drangizas/laravel-php-fpm:8.5-<short sha>`

Build locally:

```sh
docker build --target base -t ghcr.io/drangizas/laravel-php-fpm:8.5 .
```

## Production tuning

`conf/php/zz-production.ini` turns off `expose_php` and tunes opcache for
immutable images (`validate_timestamps=0`, so code only changes by deploying a
new image). `conf/php-fpm/zz-pool.conf` sizes the `www` pool from env vars,
which can be overridden per container:

| Variable | Default |
| --- | --- |
| `PHP_FPM_MAX_CHILDREN` | `20` (about 40-60 MB per worker) |
| `PHP_FPM_START_SERVERS` | `4` |
| `PHP_FPM_MIN_SPARE_SERVERS` | `2` |
| `PHP_FPM_MAX_SPARE_SERVERS` | `6` |
| `PHP_FPM_MAX_REQUESTS` | `500` |
| `PHP_FPM_REQUEST_TERMINATE_TIMEOUT` | `60s` |

FPM health probe (not routed by nginx, FastCGI only):

```sh
SCRIPT_NAME=/fpm-ping SCRIPT_FILENAME=/fpm-ping REQUEST_METHOD=GET \
  cgi-fcgi -bind -connect 127.0.0.1:9000
```

The image is also rebuilt weekly without cache to pick up Debian and PHP
security patches.
