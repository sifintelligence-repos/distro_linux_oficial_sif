#!/bin/bash
# manage-users.sh
# Gestión de usuarios SIF (crear, listar, modificar grupos, eliminar)
# Debe ejecutarse como root.

set -euo pipefail

BASE="/opt/sif/firma_inteligencia"
LOG_FILE="/var/log/sif-manage-users.log"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log()  { echo -e "${GREEN}[INFO]${NC} $1" | tee -a "$LOG_FILE"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"; }
error(){ echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"; exit 1; }
info() { echo -e "${BLUE}[INFO]${NC} $1"; }

# Roles válidos (grupo principal)
declare -A ROLES=(
    [admin]="sif-admin"
    [direccion]="sif-direccion"
    [cto]="sif-cto"
    [cfo]="sif-cfo"
    [coo]="sif-coo"
    [desarrollador]="sif-desarrolladores"
    [kernel]="sif-kernel"
    [hardware]="sif-hardware"
    [qa]="sif-qa"
    [osint]="sif-osint"
    [finint]="sif-finint"
    [geoint]="sif-geoint"
    [cyberint]="sif-cyberint"
    [socmint]="sif-socmint"
    [humint]="sif-humint"
    [due-diligence]="sif-due-diligence"
    [aml]="sif-aml"
    [esg]="sif-esg"
    [riesgo-pais]="sif-riesgo-pais"
    [seguridad-corp]="sif-seguridad-corp"
    [analista]="sif-analistas"
    [operaciones]="sif-operaciones"
    [finanzas]="sif-finanzas"
    [rrhh]="sif-rrhh"
    [auditor]="sif-auditor"
    [comercial]="sif-comercial"
    [marketing]="sif-marketing"
    [academia]="sif-academia"
    [cliente]="sif-clientes"
    [readonly]="sif-readonly"
)

# Grupos secundarios recomendados por rol
declare -A SECONDARY_GROUPS=(
    [osint]="sif-analistas"
    [finint]="sif-analistas"
    [geoint]="sif-analistas"
    [cyberint]="sif-analistas"
    [socmint]="sif-analistas"
    [humint]="sif-analistas"
    [due-diligence]="sif-analistas"
    [aml]="sif-analistas"
    [esg]="sif-analistas"
    [riesgo-pais]="sif-analistas"
    [seguridad-corp]="sif-analistas"
    [desarrollador]="sif-analistas"
    [analista]=""
)

usage() {
    cat << EOF
${CYAN}SIF User Manager${NC}
Gestión de usuarios de Strategic Intelligence Firm

Uso:
  sudo $0 create <usuario> <rol> [nombre completo]
  sudo $0 list
  sudo $0 info <usuario>
  sudo $0 add-group <usuario> <grupo>
  sudo $0 remove-group <usuario> <grupo>
  sudo $0 delete <usuario>
  sudo $0 roles

Roles disponibles:
$(printf "  - %s\n" "${!ROLES[@]}" | sort)

Ejemplos:
  sudo $0 create juan osint "Juan Pérez"
  sudo $0 create maria cto "María López"
  sudo $0 add-group juan sif-analistas
  sudo $0 info juan
  sudo $0 list
EOF
    exit 0
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "Este script debe ejecutarse como root (usa sudo)."
    fi
}

check_groups_exist() {
    if ! getent group sif-admin >/dev/null 2>&1; then
        error "Los grupos SIF no existen. Ejecuta primero setup-permissions.sh"
    fi
}

create_user() {
    local username="$1"
    local role="$2"
    local fullname="${3:-$username}"

    if [[ -z "$username" || -z "$role" ]]; then
        error "Uso: $0 create <usuario> <rol> [nombre completo]"
    fi

    if [[ ! -v ROLES[$role] ]]; then
        error "Rol inválido: $role\nRoles válidos: ${!ROLES[*]}"
    fi

    local primary_group="${ROLES[$role]}"
    local secondary="${SECONDARY_GROUPS[$role]:-}"

    if id "$username" &>/dev/null; then
        error "El usuario '$username' ya existe."
    fi

    log "Creando usuario: $username (rol: $role)"

    # Crear usuario con grupo principal
    useradd -m -g "$primary_group" -c "$fullname" -s /bin/bash "$username"

    # Añadir grupos secundarios
    if [[ -n "$secondary" ]]; then
        usermod -aG "$secondary" "$username"
        log "  Grupos secundarios añadidos: $secondary"
    fi

    # Forzar cambio de contraseña en el primer login
    passwd -e "$username" 2>/dev/null || true

    log "Usuario creado correctamente."
    echo
    info "Usuario : $username"
    info "Nombre  : $fullname"
    info "Rol     : $role ($primary_group)"
    info "Grupos  : $(id -nG "$username")"
    echo
    warn "Importante: establece la contraseña con:"
    echo "  sudo passwd $username"
}

list_users() {
    echo -e "${CYAN}Usuarios SIF:${NC}"
    echo "----------------------------------------"
    printf "%-18s %-25s %s\n" "USUARIO" "NOMBRE" "GRUPOS SIF"
    echo "----------------------------------------"

    # Buscar usuarios que pertenezcan a algún grupo sif-*
    for user in $(getent passwd | cut -d: -f1); do
        groups=$(id -nG "$user" 2>/dev/null || true)
        if echo "$groups" | grep -q "sif-"; then
            fullname=$(getent passwd "$user" | cut -d: -f5 | cut -d, -f1)
            sif_groups=$(echo "$groups" | tr ' ' '\n' | grep "^sif-" | tr '\n' ' ')
            printf "%-18s %-25s %s\n" "$user" "${fullname:-—}" "$sif_groups"
        fi
    done
    echo
}

user_info() {
    local username="$1"

    if [[ -z "$username" ]]; then
        error "Uso: $0 info <usuario>"
    fi

    if ! id "$username" &>/dev/null; then
        error "El usuario '$username' no existe."
    fi

    echo -e "${CYAN}Información del usuario: $username${NC}"
    echo "----------------------------------------"
    echo "UID/GID  : $(id "$username")"
    echo "Nombre   : $(getent passwd "$username" | cut -d: -f5)"
    echo "Shell    : $(getent passwd "$username" | cut -d: -f7)"
    echo "Home     : $(getent passwd "$username" | cut -d: -f6)"
    echo "Grupos   : $(id -nG "$username")"
    echo

    # Mostrar acceso efectivo a la estructura (si existe)
    if [[ -d "$BASE" ]]; then
        echo -e "${CYAN}Acceso a $BASE:${NC}"
        if sudo -u "$username" test -r "$BASE" 2>/dev/null; then
            echo "  Lectura  : Sí"
        else
            echo "  Lectura  : No"
        fi
        if sudo -u "$username" test -w "$BASE" 2>/dev/null; then
            echo "  Escritura: Sí"
        else
            echo "  Escritura: No"
        fi
    fi
}

add_group() {
    local username="$1"
    local group="$2"

    if [[ -z "$username" || -z "$group" ]]; then
        error "Uso: $0 add-group <usuario> <grupo>"
    fi

    if ! id "$username" &>/dev/null; then
        error "El usuario '$username' no existe."
    fi

    if ! getent group "$group" >/dev/null; then
        error "El grupo '$group' no existe."
    fi

    usermod -aG "$group" "$username"
    log "Grupo '$group' añadido a $username"
    echo "Grupos actuales: $(id -nG "$username")"
}

remove_group() {
    local username="$1"
    local group="$2"

    if [[ -z "$username" || -z "$group" ]]; then
        error "Uso: $0 remove-group <usuario> <grupo>"
    fi

    if ! id "$username" &>/dev/null; then
        error "El usuario '$username' no existe."
    fi

    # gpasswd es la forma más limpia de quitar un grupo
    if gpasswd -d "$username" "$group" 2>/dev/null; then
        log "Grupo '$group' eliminado de $username"
    else
        warn "No se pudo eliminar el grupo (¿el usuario no pertenecía a él?)"
    fi
    echo "Grupos actuales: $(id -nG "$username")"
}

delete_user() {
    local username="$1"

    if [[ -z "$username" ]]; then
        error "Uso: $0 delete <usuario>"
    fi

    if ! id "$username" &>/dev/null; then
        error "El usuario '$username' no existe."
    fi

    # Protección básica
    if [[ "$username" == "root" ]]; then
        error "No se puede eliminar el usuario root."
    fi

    read -p "¿Estás seguro de eliminar al usuario '$username' y su home? [y/N] " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        log "Operación cancelada."
        exit 0
    fi

    userdel -r "$username" 2>/dev/null || userdel "$username"
    log "Usuario '$username' eliminado."
}

list_roles() {
    echo -e "${CYAN}Roles disponibles:${NC}"
    echo "----------------------------------------"
    printf "%-20s %s\n" "ROL" "GRUPO PRINCIPAL"
    echo "----------------------------------------"
    for role in $(echo "${!ROLES[@]}" | tr ' ' '\n' | sort); do
        printf "%-20s %s\n" "$role" "${ROLES[$role]}"
    done
    echo
}

# ======================
# Main
# ======================
check_root

case "${1:-}" in
    create)
        check_groups_exist
        create_user "${2:-}" "${3:-}" "${4:-}"
        ;;
    list)
        list_users
        ;;
    info)
        user_info "${2:-}"
        ;;
    add-group)
        add_group "${2:-}" "${3:-}"
        ;;
    remove-group)
        remove_group "${2:-}" "${3:-}"
        ;;
    delete)
        delete_user "${2:-}"
        ;;
    roles)
        list_roles
        ;;
    *)
        usage
        ;;
esac
