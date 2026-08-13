#!/bin/sh
set -eu

WP_PATH="/var/www/html"

: "${WP_CLI_PHP_ARGS:=-d memory_limit=512M}"
export WP_CLI_PHP_ARGS

DB_PASS="$(cat "$WORDPRESS_DB_PASSWORD_FILE")"
WP_ADMIN_PASS="$(cat "$WP_ADMIN_PASSWORD_FILE")"
WP_USER_PASS="$(cat "$WP_USER_PASSWORD_FILE")"

mkdir -p "$WP_PATH"

until mysql -h"$WORDPRESS_DB_HOST" \
            -u"$WORDPRESS_DB_USER" \
            -p"$DB_PASS" \
            -e "SELECT 1" >/dev/null 2>&1
do
    echo "Waiting for MariaDB..."
    sleep 2
done

echo "MariaDB is ready!"

if ! wp core is-installed --path="$WP_PATH" --allow-root >/dev/null 2>&1; then
  echo "Installing WordPress..."

  if [ ! -f "$WP_PATH/wp-config.php" ]; then
    wp core download --path="$WP_PATH" --allow-root

    wp config create \
      --path="$WP_PATH" \
      --dbname="$WORDPRESS_DB_NAME" \
      --dbuser="$WORDPRESS_DB_USER" \
      --dbpass="$DB_PASS" \
      --dbhost="$WORDPRESS_DB_HOST" \
      --allow-root
  fi

  wp core install \
    --path="$WP_PATH" \
    --url="https://$DOMAIN_NAME" \
    --title="Inception" \
    --admin_user="$WP_ADMIN" \
    --admin_password="$WP_ADMIN_PASS" \
    --admin_email="$WP_ADMIN_EMAIL" \
    --skip-email \
    --allow-root

  wp option update home "https://$DOMAIN_NAME" --allow-root --path="$WP_PATH"
  wp option update siteurl "https://$DOMAIN_NAME" --allow-root --path="$WP_PATH"

  if ! wp user get "$WP_USER" --path="$WP_PATH" --allow-root >/dev/null 2>&1; then
    wp user create \
      "$WP_USER" \
      "$WP_USER_EMAIL" \
      --role=author \
      --user_pass="$WP_USER_PASS" \
      --path="$WP_PATH" \
      --allow-root
  fi

  echo "WordPress installed and configured."
fi

chown -R www:www "$WP_PATH"

echo "Starting php-fpm..."
exec "$@"