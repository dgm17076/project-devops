# project-devops

Automatizacion de infraestructura AWS con Python, Bash y CI/CD simulado.

## Estructura
- ec2/gestionar_ec2.py - Gestion de instancias EC2
- s3/backup_s3.sh - Respaldo de archivos a S3
- deploy.sh - Orquestador del pipeline
- config/config.env - Variables de entorno

## Uso

### EC2
python3 ec2/gestionar_ec2.py listar
python3 ec2/gestionar_ec2.py iniciar i-1234567890abcdef0

### Backup S3
bash s3/backup_s3.sh ./data mi-bucket-devops

### Pipeline completo
./deploy.sh iniciar i-1234567890abcdef0 ./data mi-bucket-devops

## Flujo Git
feature/* -> develop -> main
