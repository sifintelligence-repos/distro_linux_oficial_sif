#!/bin/bash
# setup-permissions.sh
# Crea grupos de roles y aplica permisos base + ACLs en /opt/sif/firma_inteligencia

set -e

BASE="/opt/sif/firma_inteligencia"

if [[ ! -d "$BASE" ]]; then
  echo "Error: primero ejecuta setup-structure.sh"
  exit 1
fi

echo "Creando grupos de roles..."

GROUPS=(
  sif-admin
  sif-direccion
  sif-cto
  sif-cfo
  sif-coo
  sif-desarrolladores
  sif-kernel
  sif-hardware
  sif-qa
  sif-osint
  sif-finint
  sif-geoint
  sif-cyberint
  sif-socmint
  sif-humint
  sif-due-diligence
  sif-aml
  sif-esg
  sif-riesgo-pais
  sif-seguridad-corp
  sif-analistas
  sif-operaciones
  sif-finanzas
  sif-rrhh
  sif-auditor
  sif-comercial
  sif-marketing
  sif-academia
  sif-clientes
  sif-readonly
)

for g in "${GROUPS[@]}"; do
  if ! getent group "$g" >/dev/null; then
    sudo groupadd "$g"
    echo "Grupo creado: $g"
  else
    echo "Grupo ya existe: $g"
  fi
done

# Permisos base
echo "Aplicando permisos base..."
sudo chown -R root:sif-admin "$BASE"
sudo chmod -R 750 "$BASE"

# ACL para sif-admin (acceso total)
sudo setfacl -R -m g:sif-admin:rwx "$BASE"
sudo setfacl -R -d -m g:sif-admin:rwx "$BASE"

# Ejemplos de ACLs específicas (expandir según necesidad)
echo "Aplicando ACLs de ejemplo por módulo..."

# Analistas generales pueden leer la mayoría de módulos
sudo setfacl -R -m g:sif-analistas:rx "$BASE/15_Modulos" || true

# OSINT
sudo setfacl -R -m g:sif-osint:rwx "$BASE/15_Modulos/OSINT" || true
sudo setfacl -R -d -m g:sif-osint:rwx "$BASE/15_Modulos/OSINT" || true

# FININT
sudo setfacl -R -m g:sif-finint:rwx "$BASE/15_Modulos/FININT" || true

# CTO y desarrolladores en Tecnología
sudo setfacl -R -m g:sif-cto:rwx "$BASE/22_Tecnologia" || true
sudo setfacl -R -m g:sif-desarrolladores:rwx "$BASE/22_Tecnologia/Desarrollo" || true

# Finanzas
sudo setfacl -R -m g:sif-cfo:rwx "$BASE/08_Facturacion" || true
sudo setfacl -R -m g:sif-finanzas:rwx "$BASE/08_Facturacion" || true

# RRHH
sudo setfacl -R -m g:sif-rrhh:rwx "$BASE/14_Recursos_Humanos" || true

# Auditoría
sudo setfacl -R -m g:sif-auditor:rx "$BASE/00_GOBERNANZA_Y_COMPLIANCE" || true
sudo setfacl -R -m g:sif-auditor:rx "$BASE/07_Auditorias" || true

echo "Permisos y grupos configurados."
echo "Usa 'getfacl $BASE' para verificar."
