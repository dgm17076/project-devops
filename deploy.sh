#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/deploy_$(date +%Y%m%d_%H%M%S).log"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$1] $2" | tee -a "$LOG_FILE"; }

if [ -f "$SCRIPT_DIR/config/config.env" ]; then
    source "$SCRIPT_DIR/config/config.env"
    log "INFO" "Configuracion cargada desde config.env"
fi

if [ "$#" -ne 4 ]; then
    echo "Uso: ./deploy.sh <accion> <instance_id> <directorio> <bucket>"
    echo "Ejemplo: ./deploy.sh iniciar i-1234567890abcdef0 ./data mi-bucket"
    exit 1
fi

ACCION="$1"
INSTANCE_ID="$2"
DIRECTORIO="$3"
BUCKET="$4"

log "INFO" "Iniciando pipeline DevOps"
log "INFO" "Accion: $ACCION | Instancia: $INSTANCE_ID | Dir: $DIRECTORIO | Bucket: $BUCKET"

log "INFO" "[PASO 1] Gestion EC2..."
if python3 "$SCRIPT_DIR/ec2/gestionar_ec2.py" "$ACCION" "$INSTANCE_ID"; then
    log "INFO" "EC2 completado."
else
    log "ERROR" "Fallo en EC2."
    exit 1
fi

log "INFO" "[PASO 2] Backup S3..."
if bash "$SCRIPT_DIR/s3/backup_s3.sh" "$DIRECTORIO" "$BUCKET"; then
    log "INFO" "Backup completado."
else
    log "ERROR" "Fallo en backup S3."
    exit 1
fi

log "INFO" "Pipeline finalizado exitosamente. Log: $LOG_FILE"
