#!/bin/bash

# Autor: Jorge Alberto Castro Rodríguez
# Script para validar archivo fastq
# 13/05/2026
# Version 2.2.0

####==================================####
####          CONFIGURACIÓN           ####
####==================================####

# Obtener el directorio donde está este script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUTDIR="${PROJECT_ROOT}/results"

# Bot de telegram
source "${SCRIPT_DIR}/bot_telegram.sh"  # Asumimos el mismo directorio

# Variables
directorio=$1           # Directorio con archivos fastq 

####==================================####
####   Función integridad de FASTQ   ####
####==================================####

validar_fastq() {
    local archivo="$1"
    local nombre_archivo=$(basename "$archivo")
    local lineas=0
    local reads=0
    local errores=0
    local gc_total=0
    local bases_totales=0
    local total_n=0


    stats_file=${OUTDIR}/untrimmed_qc/stats/validacion_estadisticas.csv
    # Crear directorio si no existe
    mkdir -p "$(dirname "$stats_file")"

    # Crear CSV con encabezados solo la primera vez
    if [[ ! -f "$stats_file" ]]; then
        echo "archivo,lecturas,lineas,errores,gc_porcentaje,total_n,tamano_mb" > "$stats_file"
    fi

    # Tamaño del archivo
    local tamano_bytes=$(stat -c%s "$archivo")
    local tamano_mb=$(echo "scale=2; $tamano_bytes / 1048576" | bc)

    while IFS= read -r linea; do
        ((lineas++))
        local pos=$((lineas % 4))
        
        case $pos in
            1)  # Línea de identificador
                if [[ ! "$linea" =~ ^@ ]]; then
                    echo "${nombre_archivo} - Línea $lineas: Debe empezar con '@'"
                    ((errores++))
                fi
                ;;
            2)  # Línea de secuencia
                if [[ ! "$linea" =~ ^[ATGCNRYSWKMBDHV]+$ ]]; then
                    echo "${nombre_archivo} - Línea $lineas: Caracteres no válidos en secuencia"
                    ((errores++))
                fi
                seq_len=${#linea}
                ((bases_totales += seq_len))
                
                # Contenido GC
                gc_count=$(echo "$linea" | tr -cd 'GC' | wc -c)
                ((gc_total += gc_count))
                
                # Cantidad de N's
                n_count=$(echo "$linea" | tr -cd 'N' | wc -c)
                ((total_n += n_count))

                ;;
            3)  # Línea separadora
                if [[ ! "$linea" =~ ^\+ ]]; then
                    echo "${nombre_archivo} - Línea $lineas: Debería ser '+' (separador)"
                fi
                ;;
            0)  # Línea de calidades
                if [[ ${#linea} -ne $seq_len ]]; then
                    echo "${nombre_archivo} - Línea $lineas: Calidades (${#linea}) no coinciden con secuencia ($seq_len)"
                    ((errores++))
                fi
                ((reads++))
                ;;
        esac
    done < "$archivo"
    
    # Validación final
    if [[ $((lineas % 4)) -ne 0 ]]; then
        echo "${nombre_archivo}: Corrupto - $lineas líneas (no es múltiplo de 4)"
        ((errores++))
    fi

    # Calcular porcentaje GC
    local gc_porcentaje=0
    [[ $bases_totales -gt 0 ]] && gc_porcentaje=$(echo "scale=2; $gc_total * 100 / $bases_totales" | bc)
    
    echo "${nombre_archivo}: $reads reads, $lineas líneas, errores=$errores, GC=${gc_porcentaje}%, N=${total_n}, tamaño=${tamano_mb}MB"
    tg_send "${nombre_archivo}: $reads reads, $lineas líneas, errores=$errores, GC=${gc_porcentaje}%, N=${total_n}, tamaño=${tamano_mb}MB"

    # Escribir fila en CSV
    echo "${nombre_archivo},${reads},${lineas},${errores},${gc_porcentaje},${total_n},${tamano_mb}" >> "$stats_file"
    return $errores
}

####=====================================####
#### Existencia e integridad del archivo ####
####=====================================####

if [[ ! -d $directorio ]]; then 
    echo "Directorio ${directorio} no existe"
    tg_send "Directorio ${directorio} no existe"
    exit 1
else 
    echo "Directorio ${directorio} existe"
    tg_send "Directorio ${directorio} existe"
fi

# Recorrer todos los archivos
for archivo in "$directorio"/*.fastq "$directorio"/*.fastq.gz; do
    [[ ! -f "$archivo" ]] && continue  # Saltar si no es archivo
    
    nombre_archivo=$(basename "$archivo")
    
    echo "Archivo ${nombre_archivo} existe en ${directorio}"
    tg_send "Archivo ${nombre_archivo} existe en ${directorio}"

    if [[ -s $archivo ]]; then 
        echo "Archivo ${nombre_archivo} no está vacío"
        tg_send "Archivo ${nombre_archivo} no está vacío"

        # Verificar si está comprimido y descomprimir
        if [[ "$nombre_archivo" == *.gz ]]; then
            echo "Descomprimiendo ${nombre_archivo}..."
            tg_send "Descomprimiendo ${nombre_archivo}..."

            gunzip "$archivo"
            archivo="${archivo%.gz}"
            nombre_archivo=$(basename "$archivo")
            estaba_comprimido=1

            echo "Descompresión completada: ${nombre_archivo}"
            tg_send "Descompresión completada: ${nombre_archivo}"
        fi

        if [[ $nombre_archivo =~ ^PM[0-9]{4}_S[0-9]{1,2}_R[12]\.fastq$ ]]; then
            echo "Archivo ${nombre_archivo} es válido"
            tg_send "${nombre_archivo} es válido"

            # Validar el contenido del archivo FASTQ
            echo ""
            echo "Validando contenido de ${nombre_archivo}..."
            validar_fastq "$archivo"
            echo ""
        else
            echo "Error: ${nombre_archivo} no es válido"
            tg_send "${nombre_archivo} no es válido"
        fi

       # Volver a comprimir si originalmente estaba comprimido
        if [[ $estaba_comprimido -eq 1 ]]; then
            echo "Comprimiendo ${nombre_archivo}..."
            tg_send "Comprimiendo ${nombre_archivo}..."
            gzip "$archivo"
            echo "Compresión completada: ${nombre_archivo}.gz"
            tg_send "Compresión completada: ${nombre_archivo}.gz"
        fi

    else 
        echo "Archivo ${nombre_archivo} está vacío"
        tg_send "${nombre_archivo} está vacío"
    fi
done