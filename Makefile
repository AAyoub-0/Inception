NAME = inception

COMPOSE_FILE = ./srcs/docker-compose.yml
SECRETS_SCRIPT = ./srcs/requirements/tools/create_secrets.sh
VALIDATE_SECRETS_SCRIPT = ./srcs/requirements/tools/validate_secrets.sh
VALIDATE_ENV_SCRIPT = ./srcs/requirements/tools/validate_env.sh
GENERATE_PASSWORDS ?= 0
MARIADB_VOLUME_DIR = /home/aboumall/data/mariadb
WORDPRESS_VOLUME_DIR = /home/aboumall/data/wordpress

COMPOSE = docker compose -f $(COMPOSE_FILE)

all: volumes secrets validate-secrets validate-env
	$(COMPOSE) up --build -d

volumes:
	sudo mkdir -p $(MARIADB_VOLUME_DIR) $(WORDPRESS_VOLUME_DIR)

secrets:
	GENERATE_PASSWORDS=$(GENERATE_PASSWORDS) bash $(SECRETS_SCRIPT)

password-gen:
	GENERATE_PASSWORDS=1 bash $(SECRETS_SCRIPT)

validate-secrets:
	bash $(VALIDATE_SECRETS_SCRIPT)

validate-env:
	bash $(VALIDATE_ENV_SCRIPT)

down:
	$(COMPOSE) down

down-v:
	$(COMPOSE) down -v

clean: down-v
	sudo rm -rf $(WORDPRESS_VOLUME_DIR)/* $(MARIADB_VOLUME_DIR)/*
	docker system prune -af

re: down all

.PHONY: all volumes secrets password-gen validate-secrets validate-env down down-v clean re