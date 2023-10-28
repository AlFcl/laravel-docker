#!/bin/bash

# Detectar la ruta del script actual
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Cargar las variables de entorno desde el archivo .env
if [ -f "$DIR/../.env" ]; then
    source "$DIR/../.env"
else
    echo "Archivo .env no encontrado en $DIR/../.env."
    exit 1
fi

# Comprobar si el usuario es root
if [ "$EUID" -eq 0 ]; then
    echo "Es usuario root."

    # Verificar la existencia de los directorios antes de cambiar los permisos
    if docker exec $CONTAINER_NAME [ -d "/var/www/html/storage" ] && docker exec $CONTAINER_NAME [ -d "/var/www/html/bootstrap/cache" ]; then
        # Cambiar los permisos de las carpetas
        docker exec $CONTAINER_NAME chmod -R 777 /var/www/html/storage /var/www/html/bootstrap/cache && echo "Permisos cambiados." || { echo "Error cambiando permisos en $CONTAINER_NAME"; exit 1; }
    else
        echo "Directorios storage o bootstrap/cache no encontrados en $CONTAINER_NAME"
        exit 1
    fi

    # Copiar el archivo index.php a var/www/html dentro del contenedor
    docker cp ./index.php $CONTAINER_NAME:/var/www/html/ && echo "index.php copiado." || { echo "Error copiando index.php a $CONTAINER_NAME"; exit 1; }

    # Copiar .htaccess de public a var/www/html
    docker exec $CONTAINER_NAME cp /var/www/html/public/.htaccess /var/www/html/ && echo ".htaccess copiado." || { echo "Error copiando .htaccess en $CONTAINER_NAME"; exit 1; }

else
    echo "Necesita contraseña. Por favor, ingrese la contraseña para continuar."

    # Verificar la existencia de los directorios antes de cambiar los permisos con sudo
    if sudo docker exec $CONTAINER_NAME [ -d "/var/www/html/storage" ] && sudo docker exec $CONTAINER_NAME [ -d "/var/www/html/bootstrap/cache" ]; then
        # Cambiar los permisos de las carpetas con sudo
        sudo docker exec $CONTAINER_NAME chmod -R 777 /var/www/html/storage /var/www/html/bootstrap/cache && echo "Permisos cambiados." || { echo "Error cambiando permisos en $CONTAINER_NAME"; exit 1; }
    else
        echo "Directorios storage o bootstrap/cache no encontrados en $CONTAINER_NAME"
        exit 1
    fi

    # Copiar el archivo index.php a var/www/html dentro del contenedor con sudo
    sudo docker cp ./index.php $CONTAINER_NAME:/var/www/html/ && echo "index.php copiado." || { echo "Error copiando index.php a $CONTAINER_NAME"; exit 1; }

    # Copiar .htaccess de public a var/www/html con sudo
    sudo docker exec $CONTAINER_NAME cp /var/www/html/public/.htaccess /var/www/html/ && echo ".htaccess copiado." || { echo "Error copiando .htaccess en $CONTAINER_NAME"; exit 1; }
fi
