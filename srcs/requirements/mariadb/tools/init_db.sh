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

    echo "Starting temporary MariaDB server..."
    mysqld --user=$USER --datadir=$DIR_DATA --skip-networking &
    pid="$!"

    # Attendre que le serveur démarre
    until mysqladmin ping --silent; do
        sleep 1
    done

    echo "Creating database and user..."
    mysql -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"
    mysql -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_USER_PASSWORD}';"
    mysql -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"
    mysql -e "FLUSH PRIVILEGES;"

    # Stopper le serveur temporaire
    kill "$pid"
fi

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# Lancer MariaDB en foreground
exec mysqld --user=$USER --datadir=$DIR_DATA