NAME = inception

all: up

up: 
	docker-compose -f srcs/docker-compose.yml up -d

down:
	docker-compose -f srcs/docker-compose.yml down

re: down up

clean:
	docker-compose -f srcs/docker-compose.yml rm -f

fclean: clean
	docker volume rm $(docker volume ls -q)

.PHONY: all up down re clean fclean
