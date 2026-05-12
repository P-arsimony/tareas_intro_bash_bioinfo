#!/bin/bash

# Script para concatenación de carriles de secuenciación por muestra, con verificación de integridad y generación de checksums MD5.
# Autor: Jorge Alberto Castro Rodríguez
# Ver. 2.1.1 
# 15/04/2026

####==================================####
####          CONFIGURACIÓN           ####
####==================================####

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
RAW_DATA_DIR="${PROJECT_ROOT}/data/raw/total_RNA"  
OUTPUT_DIR="${PROJECT_ROOT}/data/raw/total_RNA/cat_files"

# Bot de telegram
source "${SCRIPT_DIR}/bot_telegram.sh"  # Asumimos el mismo directorio

# Crear directorio de salida
mkdir -p "${OUTPUT_DIR}"

cd "${RAW_DATA_DIR}" || exit 1

echo "Directorio $(pwd)"
tg_send "Directorio $(pwd)"

echo "Directorio de salida ${OUTPUT_DIR}"
tg_send "Directorio de salida ${OUTPUT_DIR}"

####==================================####
####   Verificación de archivos       ####
####==================================####

echo "Buscando archivos FASTQ en ${RAW_DATA_DIR}..."
tg_send "Buscando archivos FASTQ en ${RAW_DATA_DIR}..."

ls -la *.fastq 2>/dev/null || { echo "No se encontraron archivos FASTQ"; exit 1; }

# Verificar integridad básica de archivos FASTQ

echo "Revisando integridad de archivos FASTQ..."
tg_send "Revisando integridad de archivos FASTQ..."

for fastq in *.fastq; do
    [[ -f "$fastq" ]] || continue
    lines=$(wc -l < "$fastq")
    if (( lines % 4 != 0 )); then
        echo "$fastq - $lines no son múltiplos de 4 → Archivo potencialmente corrupto"
        tg_send "$fastq - $lines no son múltiplos de 4 → Archivo potencialmente corrupto"
    else
        echo "OK: $fastq - $((lines/4)) lecturas"
        tg_send "OK: $fastq - $((lines/4)) lecturas"
    fi
done

echo "Chequeo de archivos FASTQ completado."
tg_send "Chequeo de archivos FASTQ completado."


####==================================####
####   Concatenación por lanes        ####
####==================================####

# Obtener nombres únicos de muestras (PMXXXX_SXX)
for sample in $(ls *.fastq | grep -E '_L00[12]_' | sed 's/_L00[12]_.*//' | sort -u); do

    echo "Procesando la muestra ${sample}"
    tg_send "Procesando la muestra ${sample}"

    # Inicializar arrays para archivos R1 y R2
    r1_files=()
    r2_files=()

    # Buscar archivos L001 y L002
    for lane in L001 L002; do
        r1_file="${sample}_${lane}_R1_001.fastq"
        r2_file="${sample}_${lane}_R2_001.fastq"

        if [[ -f "$r1_file" ]]; then
            r1_files+=("$r1_file")
            echo "$r1_file encontrado"
            tg_send "$r1_file encontrado"
        fi

        if [[ -f "$r2_file" ]]; then
            r2_files+=("$r2_file")
            echo "$r2_file encontrado"
            tg_send "$r2_file encontrado"
        fi
    done

    # Concatenar archivos R1
    if [[ ${#r1_files[@]} -gt 0 ]]; then
        cat "${r1_files[@]}" > "${OUTPUT_DIR}/${sample}_R1.fastq"
        echo "Se creó ${sample}_R1.fastq a partir de los carrile(s) ${#r1_files[@]}"
        tg_send "Se creó ${sample}_R1.fastq a partir de los carrile(s) ${#r1_files[@]}"
    else
        echo "No se encontraron archivos R1 para la muestra ${sample}"
        tg_send "No se encontraron archivos R1 para la muestra ${sample}"
    fi

    # Concatenar archivos R2
    if [[ ${#r2_files[@]} -gt 0 ]]; then
        cat "${r2_files[@]}" > "${OUTPUT_DIR}/${sample}_R2.fastq"
        echo "Se creó ${sample}_R1.fastq a partir de los carrile(s) ${#r2_files[@]}"
        tg_send "Se creó ${sample}_R1.fastq a partir de los carrile(s) ${#r2_files[@]}"
    else
        echo "No se encontraron archivos R1 para la muestra ${sample}"
        tg_send "No se encontraron archivos R1 para la muestra ${sample}"
    fi

done

####=============================####
####    Limpieza y compresión    ####
####=============================####

# Opcional: Eliminar archivos originales de lanes
echo "¿Quieres remover los archivos originales? (y/n)"
read -r respuesta
if [[ "$respuesta" == "y" || "$respuesta" == "Y" ]]; then
    rm -f -- *_L001_*.fastq *_L002_*.fastq
    echo "Archivos de carriles originales eliminados."
    tg_send "Archivos origianles conservados en ${RAW_DATA_DIR}"

else
    echo "Archivos originales conservados."
    tg_send "Archivos originales conservados en ${RAW_DATA_DIR}"
fi

# Comprimir archivos concatenados
echo "Comprimiendo archivos."
for file in "${OUTPUT_DIR}"/*.fastq; do
    if [ -f "$file" ]; then
        echo "Comprimiendo: $(basename "$file")"
        tg_send "Comprimiendo: $(basename "$file")"
        gzip "$file"
    fi
done

####=============================####
####      Generación de MD5      ####
####=============================####

# Crear directorio para md5 si no existe
MD5_DIR="${PROJECT_ROOT}/../docs/archivos_md5"
mkdir -p "${MD5_DIR}"

cd "${OUTPUT_DIR}" || exit 1
md5sum *.fastq.gz > "${MD5_DIR}/md5sums_concatenados.txt"
echo ""
echo "MD5 guardados en ${MD5_DIR}/md5sums_concatenados.txt"
tg_send echo "MD5 guardados en ${MD5_DIR}/md5sums_concatenados.txt"


echo "Los archivos concatenados se encuentran en: ${OUTPUT_DIR}"
tg_send "Los archivos concatenados se encuentran en: ${OUTPUT_DIR}"

