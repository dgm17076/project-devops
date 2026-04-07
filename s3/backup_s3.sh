#!/bin/bash
set -euo pipefail

LOG_DIR="$(dirname "$0")/../logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/backup_$(date +%Y%m%d_%H%M%S).log"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$1] $2" | tee -a "$LOG_FILE"; }

if [ "$#" -ne 2 ]; then
    echo "Uso: bash backup_s3.sh <directorio> <bucket>"
    exit 1
fi

DIRECTORIO="$1"
BUCKET="$2"

if [ ! -d "$DIRECTORIO" ]; then
    log "ERROR" "El directorio '$DIRECTORIO' no existe."
    exit 1
fi

log "INFO" "Iniciando backup de '$DIRECTORIO' hacia s3://$BUCKET"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
ARCHIVO="/tmp/backup_${TIMESTAMP}.tar.gz"

log "INFO" "Comprimiendo archivos..."
tar -czf "$ARCHIVO" -C "$(dirname "$DIRECTORIO")" "$(basename "$DIRECTORIO")"
log "INFO" "Compresion exitosa."

log "INFO" "Subiendo a s3://$BUCKET/backups/backup_${TIMESTAMP}.tar.gz"
aws s3 cp "$ARCHIVO" "s3://$BUCKET/backups/backup_${TIMESTAMP}.tar.gz"
log "INFO" "Backup completado exitosamente."

rm -f "$ARCHIVO"
log "INFO" "Archivo temporal eliminado. Log: $LOG_FILE"
