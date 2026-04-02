#!/bin/bash

# Creamos un directorio dentro de $HOME llamado backups
backups="$HOME/backups" 
mkdir -p "$backups" # Directorio general de respaldos

backup_dir="$backups/backup_$(date +%Y%m%d)"
mkdir -p "$backup_dir" # Directorios por fecha del día en que se realizó el respaldo

# Copiar archivos y directorios de la variable $HOME
<<<<<<< HEAD
backup_dir="$HOME/backup_$(date +%Y%m%d)"
mkdir -p "$backup_dir"

cp -a --backup $HOME/. "$backup_dir/";
=======
cp -a "$HOME/." "$backup_dir/"

7z a "$backups/backup_$(date +%Y%m%d).7z" "$backup_dir"

rm -rf "$backup_dir"
>>>>>>> ffe3c508a19653cc18201f1e8243b4abe8e35dcc

7z a "${backup_dir}.7z" "$backup_dir"
