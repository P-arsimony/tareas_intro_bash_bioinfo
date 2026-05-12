#!/bin/bash
# Módulo de calidad de secuencias
# Autor: Jorge Alberto Castro Rodríguez
# Ver. 2.0.0
# 06/05/2026

####==================================####
####          CONFIGURACIÓN           ####
####==================================####

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# Cargar bot de telegram
source "${SCRIPT_DIR}/bot_telegram.sh"

# Directorios de trabajo
WORKDIR="${1:-${PROJECT_ROOT}/data/raw/total_RNA/cat_files}"
OUTPUT_BASE="${2:-${PROJECT_ROOT}/results}"

# Configuración de contenedores
CONTAINER="${PROJECT_ROOT}/containers/pipeline_calidad.sif"

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

    # Validación de directorio de entrada
    if [ ! -d "$input_dir" ]; then
        echo "Error: directorio ${input_dir} no existe"
        return 1
    fi

    # Conteo de archivos
    local total_files=$(find "$input_dir" \( -name "*.fastq" -o -name "*.fastq.gz" \) -type f | wc -l)
    local current=0
    
    while IFS= read -r file; do
        ((current++))
        local file_basename=$(basename "$file")
        echo "[${current}/${total_files}] Procesando: ${file_basename}"
        tg_send "[${current}/${total_files}] Procesando: ${file_basename}"

        # Contenedor con FastQC
        apptainer exec \
            --bind "${input_dir}:/input:ro" \
            --bind "${output_dir}:/output" \
            "$CONTAINER" \
            fastqc "/input/${file_basename}" -o "/output"
    done < <(find "$input_dir" \( -name "*.fastq" -o -name "*.fastq.gz" \) -type f)
    
    echo "FastQC completado exitosamente"
    tg_send "FastQC completado: ${total_files} archivos procesados"
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

    # Correr MultiQC en el contenedor
    apptainer exec \
        --bind "${input_dir}:/input:ro" \
        --bind "${output_dir}:/output" \
        "$CONTAINER" \
        multiqc "/input" -o "/output"
    
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