#!/bin/sh

echo "Calling Maria ... Ring Ring .... Ring ..."

# Initialize MariaDB only if it doesn't exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB database..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
else
    echo "MariaDB database already exists. Skipping initialization."
fi

echo "Starting MariaDB in normal mode"

# Start MariaDB in the background
mysqld_safe --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0 --skip-networking=0 &

echo "Waiting for MariaDB to be fully ready..."

while ! mysqladmin ping -h 127.0.0.1 --silent; do
    echo "Still waiting..."
    sleep 2
done

echo "Maria is ready!"

# Create database and user if not exist
mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS wordpress_sb;
CREATE USER IF NOT EXISTS 'wp_user'@'%' IDENTIFIED BY 'wp_pass';
GRANT ALL PRIVILEGES ON wordpress_sb.* TO 'wp_user'@'%';
FLUSH PRIVILEGES;
EOF

echo "MariaDB is now set up and ready!"

wait
#exec mysqld_safe --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0 --skip-networking=0

