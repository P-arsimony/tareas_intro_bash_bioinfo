#!/bin/bash

# Autor: Jorge Alberto Castro Rodríguez
# Script para validar archivo fasta y extraer nombre de muestra
# 02/04/2026
# Version 1.0.0

source .env # Cargar variables de entorno para bot de Telegram.
    
local filename=$1           # Parametro 1: nombre de archivo fastq 
local option="${2:-sample}" # Parametro 2: opción que define. Por default se toma la opción "sample" si no se proporciona parametro $2.

#### Verificar existencia del archivo ####


# Patrón para validar el archivo: 
## 1. Es un archivo con extensión .fastq
## 2. Cumple con el formato: PM\d{4}_S\d{1,2}_R[1,2]

for i in $filename; do
    if [[ -f $filename ]];
        then 
            echo "Archivo ${filename} existe"
            tg_send "Archivo ${filename} existe"
        
        else 
            echo "Archivo ${filename} NO existe"
            tg_send "Archivo ${filename} NO existe"
            exit 0

    if [[ -z $filename ]];
        then 
            echo "Archivo ${filename} no está vacío"
            tg_send "Archivo ${filename} no está vacío"
        else 
            echo "Archivo ${filename} está vacío"
            tg_send "Archivo ${filename} está vacío"
            exit 0

    if 

        else
            echo "Error: El archivo ${filename} no existe"
            tg_send "Archivo ${filename} NO es válido"
            exit 0
done

