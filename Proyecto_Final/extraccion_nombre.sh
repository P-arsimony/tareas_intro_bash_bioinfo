#!/bin/bash

# Autor: Jorge Alberto Castro Rodríguez
# Script para validar archivo fasta y extraer nombre de muestra
# 13/04/2026
# Version 3.0.0

####==================================####
####          CONFIGURACIÓN           ####
####==================================####

# Obtener el directorio donde está este script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Importar funciones de bot
source "${SCRIPT_DIR}/bot_telegram.sh"  # Asumimos el mismo directorio

# Variables
directorio=$1           # Parametro 1: directorio con archivos fastq 
option="${2:-sample}"   # Parametro 2: opción que define

####==================================####
#### Verificar existencia del archivo ####
####==================================####

if [[ ! -d $directorio ]]; then 
    echo "Directorio ${directorio} no existe"
    tg_send "Directorio ${directorio} no existe"
    exit 1
else 
    echo "Directorio ${directorio} existe"
    tg_send "Directorio ${directorio} existe"
fi

# Recorrer todos los archivos
for archivo in "$directorio"/*.fastq; do
    [[ ! -f "$archivo" ]] && continue  # Saltar si no es archivo
    
    nombre_archivo=$(basename "$archivo")
    
    echo "Archivo ${nombre_archivo} existe en ${directorio}"
    tg_send "Archivo ${nombre_archivo} existe en ${directorio}"

    if [[ -s $archivo ]]; then 
        echo "Archivo ${nombre_archivo} no está vacío"
        tg_send "Archivo ${nombre_archivo} no está vacío"

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
done

####==================================####
####   Función de cambio de nombre    ####
####==================================####

extraccion_nombre() {
    local archivo=$1
    local opcion="${2:-sample}"
    local basename=$(basename "$archivo" .fastq)
    
    local sample_part=$(echo "$basename" | cut -d'_' -f1)
    local read_part=$(echo "$basename" | grep -o 'R[12]$')
    
    case $opcion in
        "sample") echo "$sample_part" ;;
        "read") echo "$read_part" ;;
        "full") echo "${sample_part}_${read_part}" ;;
        "with_lane") echo "$basename" ;;
        *) echo "$basename" ;;
    esac
}