NAME = inception

COMPOSE_FILE = ./srcs/docker-compose.yml

COMPOSE = docker compose -f $(COMPOSE_FILE)

all:
	$(COMPOSE) up --build -d

down:
	$(COMPOSE) down

down-v:
	$(COMPOSE) down -v

clean: down-v
	sudo rm -rf /home/aboumall/data/wordpress/* /home/aboumall/data/mariadb/*
	docker system prune -af

re: down all

.PHONY: all down clean re