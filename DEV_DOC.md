## Prerequistes

Make sure you have all these prerequistes before running the project.

- Secrets  
A "secrets" directory must be present in the root of the project, the "make" command creates it but u can do it yourself. If you use "make" to create it u must fill the secrets files.


- Secrets files and passwords  
In the "secrets" directory must be 4 files with the following names: `db_password.txt` `db_root_password.txt` `db_sup_password.txt` and `wp_admin_password.txt`.
The project wont run if the passwords are empty or password too shorts, passwords must be at least 8 characters.


- env file  
You must include a .env file, an example is present in the Git repository ".env.example" just change the name to ".env", this file must be in "srcs" directory.
You may fill the environment variables, just note that the project wont run if the wordpess admin username contains "admin/Admin" or "admin-
istrator/Administrator". Also the environment variables must keep their originale names which are : `DOMAIN_NAME` `MYSQL_DATABASE` `MYSQL_USER` `MYSQL_SUP_USER` `WP_ADMIN_EMAIL` `WP_USER` and `WP_USER_EMAIL`.

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