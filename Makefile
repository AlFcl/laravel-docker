include .env
export

setup:
	@make build
	@make up 
	@make composer-update
build:
	docker-compose build --no-cache --force-rm
stop:
	docker-compose stop
up:
	docker-compose up -d
composer-update:
	docker exec $(CONTAINER_NAME) bash -c "composer update"
data:
	docker exec $(CONTAINER_NAME) bash -c "php artisan migrate"
	docker exec $(CONTAINER_NAME) bash -c "php artisan db:seed"
