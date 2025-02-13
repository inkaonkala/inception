#!/bin/sh

echo "Waiting for Maria <3 ..."
while ! mysqladmin ping -h mariadb --silent; do
        sleep 2
        echo "WAITING"
done
sleep 10

echo "Maria is ready for WP"

# Install WP-CLI
if ! command -v wp &> /dev/null; then
        echo "Installing WP-CLI ..."
        curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
        chmod +x wp-cli.phar
        mv wp-cli.phar /usr/local/bin/wp
fi

# Install Phar
if ! php -m | grep -q Phar; then
   echo "ERROR: Missing Phar"
   exit 1
fi

# Install WordPress
if [ ! -f "/var/www/html/wp-config.php" ]; then
   echo "Installing WordPress .."
   wp core download --path="/var/www/html" --allow-root
   wp config create --path="/var/www/html" --dbname="$MYSQL_DATABASE" --dbuser="$MYSQL_USER" --dbpass="$MYSQL_PASSWORD" --dbhost=mariadb --allow-root
   wp core install --path="/var/www/html" --url="https://$DOMAIN_NAME" --title="The Awesome WP Site" --admin_user="$WP_ADMIN_USER" --admin_password="$WP_ADMIN_PASS" --admin_email="$ADMIN_EMAIL" --allow-root

   chown -R nobody:nogroup /var/www/html
   chmod -R 755 /var/www/html
else
  echo "WP already installed"
fi

echo "WP setup done!"

# Ensure PHP-FPM listens on the correct port
sed -i 's|listen = 127.0.0.1:9000|listen = 0.0.0.0:9000|' /etc/php81/php-fpm.d/www.conf

exec php-fpm81 -F

