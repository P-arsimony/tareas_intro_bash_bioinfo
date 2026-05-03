#!/bin/bash

# Script for lane concatenation
# Author: Jorge Alberto Castro Rodríguez
# Ver. 2.1.1 (Adapted for Proyecto_Final structure)
# 15/04/2026

####==================================####
####          CONFIGURACIÓN           ####
####==================================####

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"  # Ya que estás en Proyecto_Final
RAW_DATA_DIR="${PROJECT_ROOT}/muestras"  # Tus archivos FASTQ están aquí
OUTPUT_DIR="${PROJECT_ROOT}/muestras/cat_files"  # Directorio para archivos concatenados

# Crear directorio de salida
mkdir -p "${OUTPUT_DIR}"

cd "${RAW_DATA_DIR}" || exit 1

echo "Working directory: $(pwd)"
echo "Output directory: ${OUTPUT_DIR}"
echo ""

####==================================####
####   Verificación de archivos       ####
####==================================####

echo "Checking FASTQ files in ${RAW_DATA_DIR}..."
ls -la *.fastq 2>/dev/null || { echo "No FASTQ files found!"; exit 1; }

# Verificar integridad básica de archivos FASTQ
echo ""
echo "Checking for corrupt FASTQ files..."
for fastq in *.fastq; do
    [[ -f "$fastq" ]] || continue
    lines=$(wc -l < "$fastq")
    if (( lines % 4 != 0 )); then
        echo "❌ CORRUPT: $fastq - $lines lines (not multiple of 4)"
    else
        echo "✓ OK: $fastq - $((lines/4)) reads"
    fi
done

echo "Corrupt file checking DONE"
echo ""

####==================================####
####   Concatenación por lanes        ####
####==================================####

# Obtener nombres únicos de muestras (PMXXXX_SXX)
# Nota: Tus archivos tienen formato PM2486_S27_L002_R1_001.fastq
for sample in $(ls *.fastq | grep -E '_L00[12]_' | sed 's/_L00[12]_.*//' | sort -u); do

    echo "Processing sample: ${sample}"

    # Inicializar arrays para archivos R1 y R2
    r1_files=()
    r2_files=()

    # Buscar archivos L001 y L002
    for lane in L001 L002; do
        r1_file="${sample}_${lane}_R1_001.fastq"
        r2_file="${sample}_${lane}_R2_001.fastq"

        if [[ -f "$r1_file" ]]; then
            r1_files+=("$r1_file")
            echo "  Found: $r1_file"
        fi

        if [[ -f "$r2_file" ]]; then
            r2_files+=("$r2_file")
            echo "  Found: $r2_file"
        fi
    done

    # Concatenar archivos R1
    if [[ ${#r1_files[@]} -gt 0 ]]; then
        cat "${r1_files[@]}" > "${OUTPUT_DIR}/${sample}_R1.fastq"
        echo "  ✓ Created: ${sample}_R1.fastq from ${#r1_files[@]} lane(s)"
    else
        echo "  ⚠ Warning: No R1 files found for sample ${sample}"
    fi

    # Concatenar archivos R2
    if [[ ${#r2_files[@]} -gt 0 ]]; then
        cat "${r2_files[@]}" > "${OUTPUT_DIR}/${sample}_R2.fastq"
        echo "  ✓ Created: ${sample}_R2.fastq from ${#r2_files[@]} lane(s)"
    else
        echo "  ⚠ Warning: No R2 files found for sample ${sample}"
    fi

    echo ""
done

####==================================####
####   Limpieza y compresión          ####
####==================================####

# Opcional: Eliminar archivos originales de lanes
echo "Do you want to remove original lane files? (y/n)"
read -r respuesta
if [[ "$respuesta" == "y" || "$respuesta" == "Y" ]]; then
    rm -f -- *_L001_*.fastq *_L002_*.fastq
    echo "Original lane files removed."
else
    echo "Original lane files kept."
fi

# Comprimir archivos concatenados
echo ""
echo "Compressing concatenated files..."
for file in "${OUTPUT_DIR}"/*.fastq; do
    if [ -f "$file" ]; then
        echo "  Compressing: $(basename "$file")"
        gzip "$file"
    fi
done

####==================================####
####   Generación de MD5              ####
####==================================####

# Crear directorio para md5 si no existe
MD5_DIR="${PROJECT_ROOT}/../docs/md5_files"
mkdir -p "${MD5_DIR}"

cd "${OUTPUT_DIR}" || exit 1
md5sum *.fastq.gz > "${MD5_DIR}/md5sums_concatenated.txt"
echo ""
echo "MD5 checksums saved to: ${MD5_DIR}/md5sums_concatenated.txt"

echo ""
echo "=========================================="
echo "Process completed successfully!"
echo "Concatenated files are in: ${OUTPUT_DIR}"
echo "=========================================="
