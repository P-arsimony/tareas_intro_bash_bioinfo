#!/bin/bash

# Autor: Jorge Alberto Castro Rodríguez
# Script para generar directorios y verificar que existan.
# 13/04/2026
# Version 2.0.0

####==================================####
####          CONFIGURACIÓN           ####
####==================================####

# Obtener el directorio donde está este script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Directorio 

# Importar funciones de bot
source "${SCRIPT_DIR}/bot_telegram.sh"  # Asumimos el mismo directorio

# Configuración del proyecto
PROJECT_NAME="${1:-mosquito_virome_yucatan_LEVE}"
BASE_DIR="$(pwd)/${PROJECT_NAME}"

####==================================####
####    FUNCIÓN PARA CREAR DIRECTORIO ####
####==================================####

create_dir_validation() {
    local dir_path="$1"
    local dir_description="$2"
    
    if [[ -d "$dir_path" ]]; then
        echo "Directorio ya existe: ${dir_description}"
        tg_send "Directorio ya existente: ${dir_description}"

    else
        if mkdir -p "$dir_path"; then
            echo "✅ Directorio creado: ${dir_description}"
            tg_send "✅ Directorio creado: ${dir_description}"

        else
            echo "❌ Error al crear: ${dir_description}"
            tg_send "❌ Error al crear directorio: ${dir_description}"
            exit 1

        fi
    fi
}


####==================================####
####    CREACIÓN DE DIRECTORIOS       ####
####==================================####

create_directory_structure() {
    local base="$1"
    
    echo "========================================="
    echo "  Creando estructura de directorios"
    echo "  Proyecto: ${PROJECT_NAME}"
    echo "  Ubicación: ${base}"
    echo "========================================="
    
    tg_send "Iniciando creación de estructura de directorios para: ${PROJECT_NAME}"
    
    # Verificar si el directorio base existe
    create_dir_validation "$base" "Directorio base del proyecto"
    
    # Data directories
    create_dir_validation "${base}/data/raw/total_RNA" "data/raw/total_RNA"
    create_dir_validation "${base}/data/raw/small_RNA" "data/raw/small_RNA"
    create_dir_validation "${base}/data/metadata" "data/metadata"
    
    # Directorio de referencias
    create_dir_validation "${base}/data/references/mosquito_genomes/aedes_super_index" "Referencias: genoma Aedes"
    create_dir_validation "${base}/data/references/databases/BLAST" "Referencias: BLAST DB"
    create_dir_validation "${base}/data/references/databases/DIAMOND" "Referencias: DIAMOND DB"
    
    # Directorio de resultados 
    create_dir_validation "${base}/results/untrimmed_qc/fastqc" "Resultados: FastQC (sin trimming)"
    create_dir_validation "${base}/results/untrimmed_qc/multiqc" "Resultados: MultiQC (sin trimming)"
    create_dir_validation "${base}/results/trimmed_qc/fastqc" "Resultados: FastQC (con trimming)"
    create_dir_validation "${base}/results/trimmed_qc/multiqc" "Resultados: MultiQC (con trimming)"
    
    # Directorio de resultados 
    create_dir_validation "${base}/results/trimmed" "Resultados: Secuencias trimmed"
    create_dir_validation "${base}/results/aligned" "Resultados: Alineamientos"
    create_dir_validation "${base}/results/assembly/statistics" "Resultados: Estadísticas ensamblajes"
    create_dir_validation "${base}/results/assembly/rnaSPAdes" "Resultados: Ensamblaje rnaSPAdes"
    create_dir_validation "${base}/results/assembly/metaSPAdes" "Resultados: Ensamblaje metaSPAdes"
    create_dir_validation "${base}/results/assembly/MEGAhit" "Resultados: Ensamblaje MEGAhit"
    
    # Directorio de logs
    create_dir_validation "${base}/logs/trimming" "Logs: Trimmomatic"
    create_dir_validation "${base}/logs/mapping" "Logs: Alineamiento con STAR"
    create_dir_validation "${base}/logs/assembly" "Logs: Ensamblaje"
    create_dir_validation "${base}/logs/blast" "Logs: BLAST/DIAMOND"
    
    # Directorios de scripts y documentos
    create_dir_validation "${base}/docs/aedes_genomes_specs" "Documentación: Especificaciones genomas"
    create_dir_validation "${base}/scripts/aedes_reference_genomes" "Scripts: Referencias genomas"
    create_dir_validation "${base}/scripts/databases" "Scripts: Bases de datos"
    create_dir_validation "${base}/scripts/pipeline_whole" "Scripts: Pipeline completo"
    create_dir_validation "${base}/scripts/individual_analyses" "Scripts: Análisis individuales"

}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    create_directory_structure "$BASE_DIR"
    
    echo ""
    echo "========================================="
    echo "Proceso completado exitosamente"
    echo "Ubicación del proyecto: ${BASE_DIR}"
    echo "========================================="

fi