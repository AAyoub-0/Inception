#!/bin/sh

set -e

WP_PATH=/var/www/html

echo "Waiting for MariaDB..."
sleep 10

echo "MariaDB is up!"

if [ ! -f "$WP_PATH/wp-config.php" ]; then
  echo "Installing WordPress..."

  wp core download --path="$WP_PATH" --allow-root

  echo "WordPress downloaded."

  echo "Configuring WordPress..."

  wp config create \
    --path="$WP_PATH" \
    --dbname="$WORDPRESS_DB_NAME" \
    --dbuser="$WORDPRESS_DB_USER" \
    --dbpass="$(cat $WORDPRESS_DB_PASSWORD_FILE)" \
    --dbhost="$WORDPRESS_DB_HOST" \
    --allow-root

  wp core install \
    --path="$WP_PATH" \
    --url="https://$DOMAIN_NAME" \
    --title="Inception" \
    --admin_user="$WP_ADMIN_USER" \
    --admin_password="$(cat $WP_ADMIN_PASSWORD_FILE)" \
    --admin_email="$WP_ADMIN_EMAIL" \
    --allow-root

  wp user create \
    "$WP_USER_USER" \
    "$WP_USER_EMAIL" \
    --role=author \
    --user_pass="$(cat $WP_USER_PASSWORD_FILE)" \
    --path="$WP_PATH" \
    --allow-root
fi

echo "Starting PHP-FPM..."
exec php-fpm81 -F