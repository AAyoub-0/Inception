## Services

This stack provides 3 services built by a docker-compose configuration file.

- Mariadb (database)
- Nginx (Backend server)
- Wordpress (Website)

## Start and stop the project

The project is built by a docker-compose and uses a Makefile to run everything needed.
Here is the commands to run and stop the project.

```shell
make
```
This command runs everything, creating the secrets files, checking the secrets files, checking the `.env` file, building the images with docker-compose and running the containers. If the secrets files or the env file are not valid the containers wont start.

```shell
make up
```
This command starts existing containers in detached mode without forcing a rebuild. Use it after `make down` when no image or Dockerfile change was made.

```shell
make password-gen
```
This command generates passwords inside the secret files created by `make secrets`. It does not overwrite files that already contain a password.

```shell
make validate-secrets
```
This command checks that the 4 secret files exist, are not empty, and have passwords with at least 8 characters.

```shell
make validate-env
```
This command checks that `srcs/.env` exists, that it contains all required environment variable names from `srcs/.env.example`, and that `WP_ADMIN` does not contain `admin` or `administrator`.

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