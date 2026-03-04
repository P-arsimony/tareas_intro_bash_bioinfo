#!/bin/bash

# Copiar archivos y directorios de la variable $HOME
backup_dir="$HOME/backup_$(date +%Y%m%d)"
mkdir -p "$HOME/backup"

for homedir in "$HOME"/*; 
do 
    cp -a --backup $HOME "$backup_dir";
done

7z a "backup_$(date +%Y%m%d).7z" "$backup_dir"


