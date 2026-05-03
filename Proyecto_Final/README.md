# __Validación de archivos FASTQ de secuencación de transcriptomas de mosquitos de las especies *Aedes serratus* y *Aedes taeniorhynchus* de la península de Yucatán, México.__

## Introducción


## Objetivo
El objetivo de este proyecto es validar la integridad de los archivos FASTQ obtenidos de la secuenciación de transcriptomas de mosquitos de las especies *Ae. serratus* y *Ae. taeniorhynchus* de la península de Yucatán, México. Esta validación es crucial para asegurar la calidad de los datos antes de proceder con análisis posteriores, como el ensamblaje y la anotación de secuencias virales presentes en los mosquitos.

## Descripción general del proyecto
El proyecto se divide en varias etapas. 

Este script se enfoca en una etapa no contemplada en un principio durante el planteamiento del flujo de trabajo, sin embargo, importante para asegurar la integridad de los análisis posteriores. La idea en general es establecer un flujo de trabajo para validación de los datos, que incluya la concatenación de archivos de carriles (L001 y L002), la validación de la estructura de los archivos FASTQ, la generación de sumas de verificación MD5 y una prueba de validación de la calidad de las secuencias con FastQC y MultiQC.

## Estructura del proyecto
Gran parte de los scripts y análisis dependen de la organización de archivos y directorios como se muestra a continuación. En el caso de que se modifique dicha organización, es importante actualizar
los scripts en consideración de cualquier cambio realizado.

```
mosquito_virome_yucatan_LEVE/
│
├── data/
│   ├── raw/
│   |   ├── total_RNA/
│   |   │   └── [samples]
│   |   ├── small_RNA/
│   |   │   └── [samples]/
│   |   └── metadata/
│   |       └── [metadata files]
│   ├── references/
|   │   ├── mosquito_genomes/
|   │   │   └── aedes_super_index/
|   │   └── databases/
|   │       ├── BLAST/
|   │       └── DIAMOND/
│
├── results/
│   ├── untrimmed_qc/
│   │   └── fastqc/
│   │   └── multiqc/
│   ├── trimmed/
│   ├── trimmed_qc/
│   │   └── fastqc/
│   │   └── multiqc/
│   ├── aligned/
│   └── assembly/
│       ├── statistics/
│       ├── rnaSPAdes/
│       │   └── [samples]/
│       ├── metaSPAdes/
│       │   └── [samples]/
│       ├── MEGAhit/
│       │   └── [samples]/
│
├── logs/
│   ├── trimming/
│   ├── mapping/
│   ├── assembly/
│   └── blast/
│
├── docs/
│   └── aedes_genomes_specs/
│
└── scripts/
    ├── aedes_reference_genomes/
    ├── databases/
    ├── pipeline_whole/
    └── individual_analyses/
```



## Requisitos de software


## Configuración del entorno


## Uso del proyecto
El proyecto contempla distintos pasos para validar los archivos. 
1. En primer lugar, se hace una concatenación de los archivos, dado que algunos de los archivos se encuentran separados por carriles (L001 y L002).
2. En segundo lugar se hace una validación de la estructura de los directorios. 
3. En tercer lugar, se hace una validación de la estructura de los archivos FASTQ. Para esto, se espera que se tenga la siguiente estructura por lectura:
   
```
@SEQ_ID
SECUENCIA
+ (SEPARADOR)
CALIDAD
```

4. En cuarto lugar, se hace la validación de la calidad de secuencias con FastQC y MultiQC. Para esto, se escribió un script para la modificación de los nombres de los archivos FASTQ, dado que hay porciones de los nombres poco informativas.


## Entradas y salidas


## Información del sistema
El hardaware en donde se ejecutó el proyecto fue el siguiente:
- **Tipo de equipo**: Computadora de escritorio.
- **Sistema operativo**: Windows 11 Home, versión 10.0.26200, arquitectura x64.
- **CPU**: Ryzen 9 9950X @ 4.30GHz (16 núcleos, 32 hilos). Overclocking hasta 5.70GHz.
- **Memoria RAM**: 64 GB DDR5 6000 MHz. Capacidad máXima soportada por RAM: 128 Gb. 2 de 4 ranuras usadas.
- **Almacenamiento**: SSD NVMe de 2 TB.
- **GPU**: AMD Radeon RX 7700 XT 12 GB GDDR6 (no utilizada en el análisis).
- **Tiempo de ejecución**: Sólo se utilizó una pequeña porción de los .

## Autoría
- **Nombre del autor**: Jorge Alberto Castro Rodríguez
- **Tema de investigación**: Caracterización de Secuencias Virales de Especies de Mosquitos de Importancia Médica
- **Institución**: Instituto de Investigaciones Biomédicas, UNAM