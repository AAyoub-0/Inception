#!/bin/sh

set -e

DIR_DATA=/var/lib/mysql
USER=mysql

DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
DB_USER_PASSWORD=$(cat /run/secrets/db_password)

# Initialisation si nécessaire
if [ ! -d "$DIR_DATA/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mariadb-install-db --user=$USER --datadir=$DIR_DATA
fi

echo "Creating database and user via bootstrap..."
    mysqld --user=$USER --datadir=$DIR_DATA --bootstrap <<SQL
    CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_USER_PASSWORD}';
    GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
    FLUSH PRIVILEGES;
SQL

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# Lancer MariaDB en foreground
exec mysqld --user=$USER --datadir=$DIR_DATA