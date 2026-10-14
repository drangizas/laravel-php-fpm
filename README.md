# laravel-php-fpm

Slim php-fpm base image for Laravel apps: PHP 8.5 on `debian:trixie-slim` with
pdo_pgsql, pgsql, intl, zip, bcmath, soap, curl, pcntl, gd (freetype, jpeg,
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
