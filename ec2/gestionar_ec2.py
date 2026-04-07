#!/usr/bin/env python3
import sys
import boto3
from botocore.exceptions import ClientError, NoCredentialsError


def obtener_cliente():
    try:
        return boto3.client("ec2")
    except NoCredentialsError:
        print("ERROR: No se encontraron credenciales de AWS.")
        sys.exit(1)


def listar_instancias():
    ec2 = obtener_cliente()
    try:
        respuesta = ec2.describe_instances()
        instancias = []
        for reserva in respuesta["Reservations"]:
            for inst in reserva["Instances"]:
                instancias.append(inst)
        if not instancias:
            print("No se encontraron instancias EC2.")
            return
        print(f"{'ID':<22} {'Estado':<14} {'Tipo'}")
        print("-" * 55)
        for inst in instancias:
            print(f"{inst['InstanceId']:<22} {inst['State']['Name']:<14} {inst['InstanceType']}")
    except ClientError as e:
        print(f"ERROR: {e}")
        sys.exit(1)


def iniciar_instancia(instance_id):
    ec2 = obtener_cliente()
    try:
        ec2.start_instances(InstanceIds=[instance_id])
        print(f"Instancia {instance_id} iniciada correctamente.")
    except ClientError as e:
        print(f"ERROR: {e}")
        sys.exit(1)


def detener_instancia(instance_id):
    ec2 = obtener_cliente()
    try:
        ec2.stop_instances(InstanceIds=[instance_id])
        print(f"Instancia {instance_id} detenida correctamente.")
    except ClientError as e:
        print(f"ERROR: {e}")
        sys.exit(1)


def terminar_instancia(instance_id):
    ec2 = obtener_cliente()
    try:
        confirmacion = input(f"Terminar {instance_id}? (s/n): ")
        if confirmacion.lower() != "s":
            print("Cancelado.")
            return
        ec2.terminate_instances(InstanceIds=[instance_id])
        print(f"Instancia {instance_id} terminada.")
    except ClientError as e:
        print(f"ERROR: {e}")
        sys.exit(1)


def validar_parametros():
    acciones_sin_id = {"listar"}
    acciones_con_id = {"iniciar", "detener", "terminar"}
    acciones_validas = acciones_sin_id | acciones_con_id
    if len(sys.argv) < 2:
        print(f"Uso: python3 gestionar_ec2.py <accion> [instance_id]")
        sys.exit(1)
    accion = sys.argv[1].lower()
    if accion not in acciones_validas:
        print(f"ERROR: accion '{accion}' no reconocida.")
        sys.exit(1)
    if accion in acciones_con_id and len(sys.argv) < 3:
        print(f"ERROR: '{accion}' requiere un instance_id.")
        sys.exit(1)
    return accion


def main():
    accion = validar_parametros()
    instance_id = sys.argv[2] if len(sys.argv) >= 3 else None
    acciones = {
        "listar":   listar_instancias,
        "iniciar":  lambda: iniciar_instancia(instance_id),
        "detener":  lambda: detener_instancia(instance_id),
        "terminar": lambda: terminar_instancia(instance_id),
    }
    acciones[accion]()


if __name__ == "__main__":
    main()
