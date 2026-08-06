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
This command runs everything, creating the secrets files and checking that the configuration files are good, building the images with the docker-compose and running the containers.

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