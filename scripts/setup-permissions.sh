#!/bin/bash
# setup-permissions.sh
# Crea grupos de roles y aplica permisos base + ACLs
# Versión alineada con docs/ROLES.md

set -euo pipefail

BASE="/opt/sif/firma_inteligencia"
LOG_FILE="/var/log/sif-setup-permissions.log"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()  { echo -e "${GREEN}[INFO]${NC} $1" | tee -a "$LOG_FILE"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"; }
error(){ echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"; exit 1; }
info() { echo -e "${BLUE}[ACL]${NC} $1" | tee -a "$LOG_FILE"; }

if [[ $EUID -ne 0 ]]; then
    error "Este script debe ejecutarse como root (usa sudo)."
fi

if [[ ! -d "$BASE" ]]; then
    error "No existe $BASE. Ejecuta primero setup-structure.sh"
fi

if ! command -v setfacl &>/dev/null; then
    error "Falta el comando 'setfacl'. Instala el paquete 'acl'."
fi

log "Iniciando configuración de grupos y permisos SIF"

# 1. Grupos
GROUPS=(
    sif-admin sif-direccion sif-cto sif-cfo sif-coo
    sif-desarrolladores sif-kernel sif-hardware sif-qa
    sif-osint sif-finint sif-geoint sif-cyberint sif-socmint
    sif-humint sif-due-diligence sif-aml sif-esg sif-riesgo-pais
    sif-seguridad-corp sif-analistas
    sif-operaciones sif-finanzas sif-rrhh sif-auditor
    sif-comercial sif-marketing sif-academia
    sif-clientes sif-readonly
)

log "Creando grupos de roles..."
for g in "${GROUPS[@]}"; do
    if ! getent group "$g" >/dev/null 2>&1; then
        groupadd "$g"
        log "  Grupo creado: $g"
    else
        warn "  Grupo ya existe: $g"
    fi
done

# 2. Permisos base
log "Aplicando permisos base (root:sif-admin + 750)..."
chown -R root:sif-admin "$BASE"
chmod -R 750 "$BASE"

# 3. ACL total para admin y dirección
log "Aplicando ACL total para sif-admin y sif-direccion..."
setfacl -R -m g:sif-admin:rwx "$BASE"
setfacl -R -d -m g:sif-admin:rwx "$BASE"
setfacl -R -m g:sif-direccion:rwx "$BASE"
setfacl -R -d -m g:sif-direccion:rwx "$BASE"

# 4. Helper
apply_acl() {
    local group="$1"
    local path="$2"
    local perms="$3"

    if [[ -d "$path" ]]; then
        setfacl -R -m "g:${group}:${perms}" "$path"
        setfacl -R -d -m "g:${group}:${perms}" "$path"
        info "  $group → $path ($perms)"
    else
        warn "  Ruta no existe: $path"
    fi
}

log "Aplicando ACLs específicas por rol..."

# Inteligencia
apply_acl sif-osint            "$BASE/15_Modulos/OSINT"                    rwx
apply_acl sif-finint           "$BASE/15_Modulos/FININT"                   rwx
apply_acl sif-geoint           "$BASE/15_Modulos/GEOINT"                   rwx
apply_acl sif-cyberint         "$BASE/15_Modulos/CYBERINT"                 rwx
apply_acl sif-socmint          "$BASE/15_Modulos/SOCMINT"                  rwx
apply_acl sif-humint           "$BASE/15_Modulos/HUMINT"                   rwx
apply_acl sif-due-diligence    "$BASE/15_Modulos/DUE_DILIGENCE"            rwx
apply_acl sif-aml              "$BASE/15_Modulos/AML"                      rwx
apply_acl sif-esg              "$BASE/15_Modulos/ESG"                      rwx
apply_acl sif-riesgo-pais      "$BASE/15_Modulos/RIESGO_PAIS"              rwx
apply_acl sif-seguridad-corp   "$BASE/15_Modulos/SEGURIDAD_CORPORATIVA"    rwx
apply_acl sif-analistas        "$BASE/15_Modulos"                          rx

# Tecnología
apply_acl sif-cto              "$BASE/22_Tecnologia"                       rwx
apply_acl sif-desarrolladores  "$BASE/22_Tecnologia/Desarrollo"            rwx
apply_acl sif-desarrolladores  "$BASE/18_Automatizacion"                   rwx
apply_acl sif-kernel           "$BASE/22_Tecnologia"                       rx
apply_acl sif-kernel           "$BASE/24_Laboratorio"                      rwx
apply_acl sif-hardware         "$BASE/22_Tecnologia/Infraestructura"       rwx
apply_acl sif-hardware         "$BASE/24_Laboratorio"                      rwx
apply_acl sif-qa               "$BASE/24_Laboratorio"                      rwx
apply_acl sif-qa               "$BASE/03_Operaciones/04_Control_Calidad"   rwx

# Operaciones y Admin
apply_acl sif-operaciones      "$BASE/03_Operaciones"                      rwx
apply_acl sif-operaciones      "$BASE/02_Proyectos"                        rwx
apply_acl sif-cfo              "$BASE/08_Facturacion"                      rwx
apply_acl sif-finanzas         "$BASE/08_Facturacion"                      rwx
apply_acl sif-rrhh             "$BASE/14_Recursos_Humanos"                 rwx
apply_acl sif-auditor          "$BASE/00_GOBERNANZA_Y_COMPLIANCE"          rx
apply_acl sif-auditor          "$BASE/07_Auditorias"                       rx
apply_acl sif-auditor          "$BASE/12_Cumplimiento"                     rx
apply_acl sif-comercial        "$BASE/01_Clientes"                         rwx
apply_acl sif-comercial        "$BASE/02_Proyectos"                        rx
apply_acl sif-marketing        "$BASE/23_Activos_Digitales"                rwx
apply_acl sif-academia         "$BASE/23_Activos_Digitales"                rx
apply_acl sif-academia         "$BASE/10_Plantillas"                       rx
apply_acl sif-readonly         "$BASE"                                     rx

# Logs
log "Configurando permisos de logs..."
chmod 770 "$BASE/logs"
setfacl -m g:sif-admin:rwx "$BASE/logs"
setfacl -d -m g:sif-admin:rwx "$BASE/logs"

echo
log "=============================================="
log "  Configuración de permisos SIF completada"
log "=============================================="
echo
log "Comandos útiles:"
echo "  getfacl $BASE"
echo "  getfacl $BASE/15_Modulos/OSINT"
echo "  getent group | grep sif-"
