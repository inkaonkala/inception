FROM alpine:3.17

#Install ngginx and openSSL (for TLS)) and add certificate needed for TLS
RUN apk update && apk add --no-cache nginx openssl ca-certificates curl

#create directories for certificate
RUN mkdir -p /etc/nginx/ssl

#Copy nginx  confic file
COPY conf/nginx.conf /etc/nginx/nginx.conf

#Generate certificate 
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout /etc/nginx/ssl/nginx.key  \
	-out /etc/nginx/ssl/nginx.crt \
	-subj "/C=FI/ST=Helsinki/L=Helsinki/O=42/OU=Inception/CN=iniska.42.fr"

EXPOSE 443

ENTRYPOINT ["nginx", "-g", "daemon off;"]

