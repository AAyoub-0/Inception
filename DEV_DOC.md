## Prerequistes

Make sure you have all these prerequistes before running the project.

- Secrets  
A "secrets" directory must be present in the root of the project. The "make" command creates it automatically, but by default it only creates empty secret files.


- Secrets files and passwords  
In the "secrets" directory must be 4 files with the following names: `db_password.txt` `db_root_password.txt` `db_sup_password.txt` and `wp_admin_password.txt`.
The project wont run if the passwords are empty or password too shorts, passwords must be at least 8 characters. You can generate them with `make password-gen` after the files are created.


- env file  
You must include a .env file, an example is present in the Git repository ".env.example" just change the name to ".env", this file must be in "srcs" directory.
You may fill the environment variables, just note that the project wont run if the wordpress admin username contains `admin` or `administrator`, regardless of uppercase or lowercase. Also the environment variables must keep their originale names which are : `DOMAIN_NAME` `MYSQL_DATABASE` `MYSQL_USER` `MYSQL_SUP_USER` `WP_ADMIN` `WP_ADMIN_EMAIL` `WP_USER` and `WP_USER_EMAIL`.

## Start and stop the project with the Makefile

The project is built by a docker-compose and uses a Makefile to run everything needed.
Here is the commands to run and stop the project.

```shell
make
```
This command runs everything in order: it creates the secrets files, validates the secrets, validates the `.env` file, then builds the images with docker-compose and runs the containers. If one validation fails, nothing is built.

```shell
make password-gen
```
This command generates passwords inside the existing secret files. It only works if the 4 secret files already exist, and it does not overwrite files that already contain a password.

```shell
make validate-secrets
```
This command checks that all secret files exist, are not empty, and contain at least 8 characters.

```shell
make validate-env
```
This command checks that `srcs/.env` exists, that it contains the same variable names as `srcs/.env.example`, and that `WP_ADMIN` does not contain `admin` or `administrator`.

```shell
make down
make down -v
```
This command stops the container without destroying them. Adding the "-v" clears the volumes.

```shell
make re
```
Runs "make down" and "make", you can use this to rerun the containers, it doesnt delete volumes.

```shell
make clean
```
This command runs "make down -v", and then delete all the data inside the "user/data/mariadb" and "user/data/wordpress", and finally runs "docker system prune -af"
to make sure all images are deleted. This is used in case of bugs that can be due to volumes.

## Start and stop the project with docker-compose

You can also run this project using docker-compose directly. It is good if you want to debug.

If you want to build and run all containers:
```shell
$ cd srcs
$ docker compose up --build -d
```
The "-d" is to run it in detach mode so it doesn't use the terminal.

Use this command to stop containers:
```shell
$ docker compose down
$ docker compose down -v
```

If you stopped the containers yu can start them back with: 
```shell
$ docker compose start
```

## Debugging

### Containers

Use these commands if you want to manage containers.
These commands must be executed in srcs if you want to use "docker compose".

```sh
$ cd srcs
$ docker compose ps
```
List the containers and their state.

```sh
$ docker compose logs
$ docker compose logs -f
$ docker compose logs service_name
```
Shows the logs of docker compose or the specified service.
The "-f" follows the logs in real time.

```sh
$ docker images
```
List all images.

```sh
$ docker network ls
$ docker network inspect network_name
```
List docker networks, and inspect the specified network.

```sh
$ docker compose exec nginx bash
```
Execute a service with a custom entrypoint, this is mainly used to debug containers and enter inside, the "bash" can be replaced by any program.

### Volumes

Use these commands if you want to manage volumes.

```sh
$ docker volume ls
```
List the volumes.

```sh
$ docker volume inspect volume_name
```
Inspect a volume.

```sh
$ docker volume prune
```
Deletes all unused volumes.

## Perstistant data

The data persist due to docker named volumes, this type of volumes are directly handled by docker. There is a volume for database and wordpress. You can find the data in the following directories: "home/login/data/mariadb" and "home/login/data/wordpress" on the host machine.

