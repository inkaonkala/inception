NAME = inception

all: up

up: 
	docker-compose -f srcs/docker-compose.yml up -d

down:
	docker-compose -f srcs/docker-compose.yml down --volumes --remove-orphans

clean:
	$(MAKE) down
	docker rmi -f $$(docker images -q) 2>/dev/null || true

fclean: clean
	@if [ -n "$$(docker volume ls -q)" ]; then \
		docker volume rm $$(docker volume ls -q); \
	fi
	sudo rm -rf ~/inception/data/mariadb ~/inception/data/wordpress
	sudo rm -rf /home/iniska/data/mariadb /home/iniska/data/wordpress
	sudo rm -rf /var/lib/docker/volumes/srcs_mariadb /var/lib/docker/volumes/srcs_wordpress
	sudo mkdir -p ~/data/mariadb ~/data/wordpress

re: fclean  all

.PHONY: all up down clean fclean re
