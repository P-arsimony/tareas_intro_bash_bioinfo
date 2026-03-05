#!/bin/bash

# Creamos un directorio dentro de $HOME llamado backups
backups="$HOME/backups" 
mkdir -p "$backups" # Directorio general de respaldos

backup_dir="$backups/backup_$(date +%Y%m%d)"
mkdir -p "$backup_dir" # Directorios por fecha del día en que se realizó el respaldo

# Copiar archivos y directorios de la variable $HOME
cp -a "$HOME/." "$backup_dir/"

7z a "$backups/backup_$(date +%Y%m%d).7z" "$backup_dir"

rm -rf "$backup_dir"

