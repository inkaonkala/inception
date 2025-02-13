FROM alpine:3.17

RUN apk update && apk add --no-cache \
    php php-fpm php-mysqli php-json php-phar \
    php-mbstring php-iconv curl mariadb-client

COPY tools/setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 9000

CMD ["/usr/local/bin/setup.sh"]


