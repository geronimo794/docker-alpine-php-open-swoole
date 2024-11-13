# Build stage
FROM alpine:3.20 AS builder

# Install build dependencies
RUN apk add --no-cache \
  autoconf \
  automake \
  make \
  gcc \
  g++ \
  libtool \
  pkgconfig \
  php83-pear \
  php83-dev

RUN apk add --no-cache \
    php83-openssl

# Update pecl channel
RUN pecl channel-update pecl.php.net

# Add specific dev packages based on your extension (e.g., libmcrypt-dev)
RUN pecl install openswoole

# Final stage
FROM alpine:3.20

LABEL Maintainer="Ach Rozikin <geronimo794@gmail.com>"
LABEL Description="Container for Laravel Octane, with swoole & PHP 8.3 based on Alpine Linux."

WORKDIR /var/www/html

# Install runtime packages
RUN apk add --no-cache \
    curl \
    php83 \
    php83-bcmath \
    php83-ctype \
    php83-curl \
    php83-dom \
    php83-fileinfo \
    php83-fpm \
    php83-gd \
    php83-intl \
    php83-mbstring \
    php83-mysqli \
    php83-opcache \
    php83-openssl \
    php83-pcntl \
    php83-pdo \
    php83-pdo_mysql \
    php83-pdo_pgsql \
    php83-pdo_sqlite \
    php83-pear \
    php83-pgsql \
    php83-phar \
    php83-posix \
    php83-redis \
    php83-session \
    php83-simplexml \
    php83-sockets \
    php83-sqlite3 \
    php83-tokenizer \
    php83-xml \
    php83-xmlreader \
    php83-xmlwriter \
    supervisor

# Copy Swoole extension from builder
COPY --from=builder /usr/lib/php83/modules/openswoole.so /usr/lib/php83/modules/

# Configure PHP and supervisord
COPY config/php.ini /etc/php83/conf.d/custom.ini
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Set permissions
RUN chown -R nobody.nobody /var/www/html /run

# Switch to non-root user
USER nobody

EXPOSE 8080

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/ || exit 1


