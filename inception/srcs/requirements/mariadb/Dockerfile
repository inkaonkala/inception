FROM alpine:3.17

RUN apk update && apk add --no-cache mariadb mariadb-client

#setup scripts
COPY tools/setup.sh /usr/local/bin/

#give permission
RUN chmod +x /usr/local/bin/setup.sh


#expose the port
EXPOSE 3306

#runnin startup
CMD ["/bin/sh", "-c", "/usr/local/bin/setup.sh"]
