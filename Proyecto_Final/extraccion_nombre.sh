#!/bin/bash

# Autor: Jorge Alberto Castro Rodríguez
# Script para extraer nombre de muestra
# 14/04/2026
# Version 4.0.2

####==================================####
####          CONFIGURACIÓN           ####
####==================================####

# Variables
entrada=$1                    # Puede ser archivo o directorio
opcion="${2:-sample}"         # Opción que define (default: sample)

####==================================####
####   Función de extracción de nombre ####
####==================================####

extraccion_nombre() {
    local archivo=$1
    local opcion="${2:-sample}"
    local basename=$(basename "$archivo" .fastq)
    basename=$(basename "$basename" .fastq.gz)
    
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

####==================================####
####            EJECUCIÓN             ####
####==================================####

# Validar que la entrada existe
if [[ ! -e "$entrada" ]]; then
    echo "Error: '$entrada' no existe"
    exit 1
fi

# Si es un directorio, procesar todos los archivos .fastq
if [[ -d "$entrada" ]]; then
    for archivo in "$entrada"/*.fastq*; do
        [[ -f "$archivo" ]] || continue
        resultado=$(extraccion_nombre "$archivo" "$opcion")
        echo "$(basename "$archivo") → $resultado"
    done
# Si es un archivo, procesar solo ese
elif [[ -f "$entrada" ]]; then
    extraccion_nombre "$entrada" "$opcion"
fi