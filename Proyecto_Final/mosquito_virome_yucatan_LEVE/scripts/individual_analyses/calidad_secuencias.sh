#!/bin/bash
# Módulo de calidad de secuencias
# Autor: Jorge Alberto Castro Rodríguez
# Ver. 1.0.0
# 04/05/2026

####==================================####
####          CONFIGURACIÓN           ####
####==================================####


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Cargar función de extracción de nombre
source "${SCRIPT_DIR}/extraer_nombre.sh"
# Cargar bot de telegram
source "${SCRIPT_DIR}/bot_telegram.sh"

# Directorios de trabajo
WORKDIR="${1:-$(pwd)/data/raw/total_RNA/cat_files}"
OUTPUT_BASE="${2:-$(pwd)/results}"


####==================================####
####        FUNCIÓN FASTQC            ####
####==================================####

run_fastqc() {
    local input_dir=$1
    local output_dir=$2

    echo "Ejecutando FastQC"
    tg_send "Ejecutando FastQC" 
    echo "Entrada: ${input_dir}"
    tg_send "Entrada: ${input_dir}"
    echo "Salida: ${output_dir}"
    tg_send "Salida: ${output_dir}"

    mkdir -p "${output_dir}"

    # Count files for progress
    total_files=$(find "$input_dir" -name "*.fastq" -type f | wc -l)
    current=0
    
    find "$input_dir" -name "*.fastq" -type f | while read -r file; do
        ((current++))
        echo "[${current}/${total_files}] Procesando: $(basename "$file")"
        tg_send "[${current}/${total_files}] Procesando: $(basename "$file")"
        fastqc "$file" -o "$output_dir"
    done
    
    echo "FastQC completado exitosamente"

}

####==================================####
####         FUNCIÓN MULTIQC          ####
####==================================####

run_multiqc() {
    local input_dir=$1
    local output_dir=$2

    echo "  Ejecutando MultiQC"
    tg_send "Ejecutando MultiQC" 
    echo "Entrada: ${input_dir}"
    tg_send "Entrada: ${input_dir}"
    echo "Salida: ${output_dir}"
    tg_send "Salida: ${output_dir}"

    
    mkdir -p "${output_dir}"

    multiqc "$input_dir" -o "$output_dir"
    
    echo "MultiQC completado exitosamente"
}

####========================================####
####        EJECUCIÓN DE FUNCIONES          ####
####========================================####

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script is being executed directly
    echo "Módulo de inspección de calidad de secuencias"
    
    FASTQC_OUTPUT="${OUTPUT_BASE}/untrimmed_qc/fastqc"
    MULTIQC_OUTPUT="${OUTPUT_BASE}/untrimmed_qc/multiqc"

    # Run the pipeline steps
    run_fastqc "$WORKDIR" "$FASTQC_OUTPUT"
    run_multiqc "$FASTQC_OUTPUT" "$MULTIQC_OUTPUT"

fi