#!/bin/bash

log_event() {
    local status="$1"
    local message="$2"
    local datetime=$(date '+%Y-%m-%d %H:%M:%S')
    local fecha=$(date '+%Y-%m-%d')
    local color=""
  
    case $status in
        OK)
            color="\e[32m" # Verde
            ;;
        ERROR)
            color="\e[31m" # Rojo
            ;;
        INFO)
            color="\e[36m" # Celeste
            ;;
    esac

    echo -e "${datetime}[${status}] ${message}" >> logs/${fecha}_start.log
    echo -e "${color}${datetime}[${status}] ${message}\e[0m" # Imprime en consola con color
}

run_command() {
    local command="$1"
    local success_msg="$2"
    local error_msg="$3"

    log_event "INFO" "Ejecutando: $command"
    output=$($command 2>&1)
    if [ $? -eq 0 ]; then
        log_event "OK" "$success_msg"
        log_event "INFO" "Respuesta: $output"
    else
        log_event "ERROR" "$error_msg"
        log_event "INFO" "Respuesta: $output"
    fi
}

# Cargar las variables de entorno desde el archivo .env
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -f "$DIR/.env" ]; then
    source "$DIR/.env"
else
    log_event "ERROR" "Archivo .env no encontrado en $DIR/.env."
    exit 1
fi

if [ "$EUID" -eq 0 ]; then
    echo "Es usuario root."

    run_command "docker-compose up -d" "Contenedor iniciado." "Error iniciando contenedor."
    run_command "docker exec $CONTAINER_NAME composer create-project --prefer-dist laravel/laravel ." "Proyecto creado." "Error creando proyecto."
#CD $DIR/fix/fix.sh
    run_command "./fix/fix.sh" "Fix ejecutado." "Error ejecutando fix."

else
    echo "Necesita contraseña. Por favor, ingrese la contraseña para continuar."
    run_command "sudo docker-compose up -d" "Contenedor iniciado." "Error iniciando contenedor."
    run_command "sudo docker exec $CONTAINER_NAME composer create-project --prefer-dist laravel/laravel ." "Proyecto creado." "Error creando proyecto."
    run_command "sudo $DIR/fix/fix.sh" "Fix ejecutado." "Error ejecutando fix."
fi
