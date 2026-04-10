#!/bin/bash

# Autor: Jorge Alberto Castro Rodríguez
# Script para validar archivo fasta y extraer nombre de muestra
# 10/04/2026
# Version 2.0.0

source .env # Cargar variables de entorno para bot de Telegram.

tg_send () {
  local msg="$1"
  curl -s -X POST "https://api.telegram.org/bot${TOKEN}/sendMessage" \
    -d "chat_id=${CHAT_ID}" \
    -d "text=${msg}" \
    -d "disable_web_page_preview=true" > /dev/null
}

directorio=$1           # Parametro 1: directorio con archivos fastq 
option="${2:-sample}" # Parametro 2: opción que define. Por default se toma la opción "sample" si no se proporciona parametro $2.

####==================================####
#### Verificar existencia del archivo ####
####==================================####


# Patrón para validar el archivo: 
## 1. Es un archivo con extensión .fastq
## 2. Cumple con el formato: PM\d{4}_S\d{1,2}_R[1,2]

# Si el directorio existe y contiene archivos .fastq

if [[ ! -d $directorio ]]; then 
    echo "Directorio ${directorio} no existe"
    tg_send "Directorio ${directorio} no existe"
    exit 1
else 
    echo "Directorio ${directorio} existe"
    tg_send "Directorio ${directorio} existe"
fi

# Verificar que sean fastq en verdad.


# Recorrer todos los archivos

for archivo in "$directorio"/*.fastq; do
    # Extraer solo el nombre del archivo una sola vez
    nombre_archivo=$(basename "$archivo")
    
    # Verificar si el archivo existe
    if [[ -f $archivo ]]; then 
        echo "Archivo ${nombre_archivo} existe en ${directorio}"
        tg_send "Archivo ${nombre_archivo} existe en ${directorio}"

        # Verificar si el archivo no está vacío
        if [[ -s $archivo ]]; then 
            echo "Archivo ${nombre_archivo} no está vacío"
            tg_send "Archivo ${nombre_archivo} no está vacío"

            # Verificar el formato del nombre
            if [[ $nombre_archivo =~ ^PM[0-9]{4}_S[0-9]{1,2}_R[12]\.fastq$ ]]; then
                echo "✅ Archivo ${nombre_archivo} es válido"
                tg_send "✅ ${nombre_archivo} es válido"
            else
                echo "❌ Error: ${nombre_archivo} no es válido"
                tg_send "❌ ${nombre_archivo} no es válido"
            fi
        else 
            echo "⚠️ Archivo ${nombre_archivo} está vacío"
            tg_send "⚠️ ${nombre_archivo} está vacío"
        fi
    fi
done