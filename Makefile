NAME = inception

COMPOSE_FILE = ./srcs/docker-compose.yml

COMPOSE = docker compose -f $(COMPOSE_FILE)

all:
	$(COMPOSE) up --build -d

down:
	$(COMPOSE) down

clean:
	docker system prune -af

re: down all

.PHONY: all down clean re