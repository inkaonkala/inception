#!/bin/sh

echo "Waiting for Maria <3 ..."
while ! mysqladmin ping -h mariadb --silent; do
	sleep 2
	echo "WAITING"
done
sleep 10

echo "Maria is ready for WP"

#install WP-CLI
if ! command -v wp &> /dev/null; then
#if [ ! -f "/usr/local/bin/wp" ]; then
	echo "Istalling WP_CLI ..."
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	chmod +x wp-cli.phar
	mv wp-cli.phar /usr/local/bin/wp
fi

#install phar
if ! php -m | grep -q Phar; then
   echo : "ERROR: Missing Phar"
   exit 1
fi

if [ ! -f "/var/www/html/wp-config.php" ]; then
   echo "Installind WordPress .."
   wp core download --path="/var/www/html" --allow-root
   wp config create --path="/var/www/html" --dbname="$MYSQL_DATABASE" --dbuser="$MYSQL_USER" --dbpass="$MYSQL_PASSWORD" --dbhost=mariadb --allow-root
   wp core install  --path="/var/www/html" --url="https://$DOMAIN_NAME" --title="The Awesome WP Site, Yjay!" --admin_user="$WP_ADMIN_USER" --admin_password="$WP_ADMIN_PASS" --admin_email="iniska@student.hive.fi" --allow-root

   chown -R www-data:www-data /var/www/html
   chmod -R 755 /var/www/html
else
  echo "WP already installed"
fi

echo "WP setup done!"

#make the port not restart wrongly!
sed -i 's|listen = 127.0.0.1:9000|listen = 0.0.0.0:9000|' /etc/php81/php-fpm.d/www.conf


exec php-fpm81 -F
