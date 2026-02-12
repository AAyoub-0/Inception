#!/bin/sh

cd /var/www/html

echo "Installing WordPress..."

if [ ! -f index.php ]; then
    echo "Downloading WordPress..."
    curl -O https://wordpress.org/latest.tar.gz
    echo "Extracting WordPress..."
    tar -xzf latest.tar.gz --strip-components=1
    echo "WordPress installed successfully."
    rm latest.tar.gz
fi

if ! id www-data >/dev/null 2>&1; then
    addgroup -g 82 www-data
    adduser -D -u 82 -G www-data -s /sbin/nologin www-data
fi

chown -R www-data:www-data /var/www/html
