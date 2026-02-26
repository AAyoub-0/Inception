#!/bin/sh
set -e

DIR_DATA=/var/lib/mysql
USER=mysql

DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
DB_USER_PASSWORD=$(cat /run/secrets/db_password)

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql $DIR_DATA

if [ ! -d "$DIR_DATA/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mariadb-install-db --user=$USER --datadir=$DIR_DATA

    echo "Starting temporary MariaDB server..."
    mysqld --user=$USER --datadir=$DIR_DATA --skip-networking &
    pid="$!"

    until mysqladmin ping --silent; do
        sleep 1
    done

    echo "Securing root user..."

    mysql -u root <<-EOSQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_USER_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOSQL

    echo "Stopping temporary MariaDB..."
    kill "$pid"
    wait "$pid"
fi

echo "Starting MariaDB in foreground..."
exec mysqld --user=$USER --datadir=$DIR_DATA