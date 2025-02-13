#!/bin/sh

echo  "Waiting for Maria <3 ..."
while ! mysqladmin ping -h mariadb --silent; do
    sleep 2
    echo "WAITING"
done
sleep 10

echo "Maria is ready for WP"

# Install WP-CLI if not installed
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

# Increase PHP memory limit
echo "memory_limit = 512M" >> /etc/php81/php.ini

# Check if WordPress is already installed
if ! wp core is-installed --path="/var/www/html" --allow-root; then
    echo "Resetting WordPress files..."
    rm -rf /var/www/html/*
    
    # Download WordPress
    wp core download --path="/var/www/html" --allow-root

    # Create wp-config.php file
    echo "Configuring WordPress..."
    cat <<EOF > /var/www/html/wp-config.php
<?php
define('DB_NAME', '${MYSQL_DATABASE}');
define('DB_USER', '${MYSQL_USER}');
define('DB_PASSWORD', '${MYSQL_PASSWORD}');
define('DB_HOST', 'mariadb');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');
\$table_prefix = 'wp_';
define('WP_DEBUG', false);
if (!defined('ABSPATH')) {
    define('ABSPATH', __DIR__ . '/');
}
require_once ABSPATH . 'wp-settings.php';
EOF

    # Set correct permissions
    chown -R nobody:nogroup /var/www/html
    chmod -R 755 /var/www/html

    # Install WordPress
    echo "Installing WordPress..."
    wp core install --path="/var/www/html" \
        --url="https://$DOMAIN_NAME" \
        --title="The Awesome WP Site" \
        --admin_user="$ADMIN_USER" \
        --admin_password="$ADMIN_PASSWORD" \
        --admin_email="$ADMIN_EMAIL" \
        --allow-root
    echo "WordPress installation completed!"
else
    echo "WordPress is already installed. Skipping installation."
fi

# Create admin user if it does not exist
if ! wp user get "$WP_ADMIN_USER" --path="/var/www/html" --allow-root > /dev/null 2>&1; then
    echo "Creating admin user: $WP_ADMIN_USER"
    wp user create "$WP_ADMIN_USER" "$ADMIN_EMAIL" --role=administrator --user_pass="$WP_ADMIN_PASS" --path="/var/www/html" --allow-root
else
    echo "Admin user already exists: $WP_ADMIN_USER"
fi

# Create user_inka (without admin rights)
if ! wp user get "$WP_USER_NAME" --path="/var/www/html" --allow-root > /dev/null 2>&1; then
    echo "Creating regular user: $WP_USER_NAME"
    wp user create "$WP_USER_NAME" "$WP_USER_EMAIL" --role=subscriber --user_pass="$WP_USER_PASS" --path="/var/www/html" --allow-root
else
    echo "Regular user already exists: $WP_USER_NAME"
fi


echo "WP setup done!"

# Ensure PHP-FPM listens on the correct port
sed -i 's|listen = 127.0.0.1:9000|listen = 0.0.0.0:9000|' /etc/php81/php-fpm.d/www.conf

exec php-fpm81 -F

