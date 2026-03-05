#!/bin/bash

# Copiar archivos y directorios de la variable $HOME
backup_dir="$HOME/backup_$(date +%Y%m%d)"
mkdir -p "$backup_dir"

cp -a --backup $HOME/. "$backup_dir/";

7z a "${backup_dir}.7z" "$backup_dir"
