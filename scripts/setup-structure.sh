#!/bin/bash
# setup-structure.sh
# Crea la estructura base de carpetas de SIF en /opt/sif/firma_inteligencia
# Diseño robusto, idempotente y alineado con la arquitectura oficial.

set -euo pipefail

BASE="/opt/sif/firma_inteligencia"
LOG_FILE="/var/log/sif-setup-structure.log"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}[INFO]${NC} $1" | tee -a "$LOG_FILE"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"; }
error(){ echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"; exit 1; }

if [[ $EUID -ne 0 ]]; then
    error "Este script debe ejecutarse como root (usa sudo)."
fi

log "Iniciando creación de estructura SIF en $BASE"
mkdir -p "$BASE"

# Árbol completo de directorios
DIRS=(
    "00_GOBERNANZA_Y_COMPLIANCE/Politicas"
    "00_GOBERNANZA_Y_COMPLIANCE/Procedimientos"
    "00_GOBERNANZA_Y_COMPLIANCE/Normativas"
    "01_Clientes/Clientes_Activos/00_PLANTILLA_CLIENTE"
    "01_Clientes/Clientes_Inactivos"
    "01_Clientes/Prospectos"
    "02_Proyectos/00_PLANTILLA_PROYECTO/Analisis"
    "02_Proyectos/00_PLANTILLA_PROYECTO/Evidencias"
    "02_Proyectos/00_PLANTILLA_PROYECTO/Informes"
    "02_Proyectos/00_PLANTILLA_PROYECTO/Documentacion"
    "02_Proyectos/Activos"
    "02_Proyectos/Finalizados"
    "03_Operaciones/01_Procesos"
    "03_Operaciones/02_Procedimientos"
    "03_Operaciones/03_Flujos_Trabajo"
    "03_Operaciones/04_Control_Calidad"
    "03_Operaciones/05_Manuales"
    "03_Operaciones/06_Checklists"
    "04_Documentos/Internos"
    "04_Documentos/Externos"
    "04_Documentos/Plantillas"
    "05_Riesgos/Evaluaciones"
    "05_Riesgos/Matrices"
    "05_Riesgos/Mitigacion"
    "06_Fuentes/OSINT"
    "06_Fuentes/HUMINT"
    "06_Fuentes/Tecnicas"
    "06_Fuentes/Abiertas"
    "07_Auditorias/Internas"
    "07_Auditorias/Externas"
    "07_Auditorias/Informes"
    "08_Facturacion/Facturas"
    "08_Facturacion/Presupuestos"
    "08_Facturacion/Cobros"
    "08_Facturacion/Reportes"
    "09_Evidencias/Casos"
    "09_Evidencias/Cadena_Custodia"
    "10_Plantillas/plantillas"
    "10_Plantillas/Documentos"
    "10_Plantillas/Emails"
    "11_Reportes/Ejecutivos"
    "11_Reportes/Tecnicos"
    "11_Reportes/Periodicos"
    "12_Cumplimiento/ISO27001"
    "12_Cumplimiento/SOC2"
    "12_Cumplimiento/GDPR"
    "12_Cumplimiento/Normativas_Locales"
    "14_Recursos_Humanos/Personal"
    "14_Recursos_Humanos/Contratos"
    "14_Recursos_Humanos/Evaluaciones"
    "14_Recursos_Humanos/Formacion"
    "14_Recursos_Humanos/Organigrama"
    "15_Modulos/AML/00_Manuales"
    "15_Modulos/AML/07_Casos"
    "15_Modulos/AML/08_Informes"
    "15_Modulos/AML/09_Base_Conocimiento"
    "15_Modulos/CYBERINT/Casos"
    "15_Modulos/CYBERINT/Informes"
    "15_Modulos/CYBERINT/Herramientas"
    "15_Modulos/DUE_DILIGENCE/Casos"
    "15_Modulos/DUE_DILIGENCE/Informes"
    "15_Modulos/ESG/Casos"
    "15_Modulos/ESG/Informes"
    "15_Modulos/FININT/Casos"
    "15_Modulos/FININT/Informes"
    "15_Modulos/FININT/Fuentes"
    "15_Modulos/GEOINT/Casos"
    "15_Modulos/GEOINT/Informes"
    "15_Modulos/GEOINT/Mapas"
    "15_Modulos/HUMINT/Casos"
    "15_Modulos/HUMINT/Informes"
    "15_Modulos/ISO27001"
    "15_Modulos/LITIGATION_SUPPORT"
    "15_Modulos/OSINT/Casos"
    "15_Modulos/OSINT/Informes"
    "15_Modulos/OSINT/Fuentes"
    "15_Modulos/OSINT/Herramientas"
    "15_Modulos/RIESGO_PAIS/Evaluaciones"
    "15_Modulos/RIESGO_PAIS/Informes"
    "15_Modulos/SEGURIDAD_CORPORATIVA/Casos"
    "15_Modulos/SEGURIDAD_CORPORATIVA/Informes"
    "15_Modulos/SOC2"
    "15_Modulos/SOCMINT/Casos"
    "15_Modulos/SOCMINT/Informes"
    "15_Modulos/CATALOGO_SERVICIOS"
    "18_Automatizacion/CLI"
    "18_Automatizacion/APIs"
    "18_Automatizacion/Agentes_IA"
    "18_Automatizacion/Dashboards"
    "18_Automatizacion/Bots"
    "18_Automatizacion/Scripts"
    "22_Tecnologia/Arquitectura"
    "22_Tecnologia/Desarrollo"
    "22_Tecnologia/IA"
    "22_Tecnologia/Infraestructura"
    "22_Tecnologia/Redes"
    "22_Tecnologia/Seguridad"
    "22_Tecnologia/Servidores"
    "22_Tecnologia/Documentacion"
    "23_Activos_Digitales/Audio"
    "23_Activos_Digitales/Imagenes"
    "23_Activos_Digitales/Videos"
    "23_Activos_Digitales/Plantillas"
    "23_Activos_Digitales/Branding"
    "24_Laboratorio/Benchmarks"
    "24_Laboratorio/Dataset"
    "24_Laboratorio/Experimentos"
    "24_Laboratorio/Sandbox"
    "24_Laboratorio/Pruebas"
    "25_Archivado/Casos_Cerrados"
    "25_Archivado/Proyectos_Finalizados"
    "25_Archivado/Documentos_Historicos"
    "logs"
)

log "Creando directorios..."
for d in "${DIRS[@]}"; do
    mkdir -p "$BASE/$d"
done

log "Creando archivos base..."
touch "$BASE/manifest.json" "$BASE/config.yaml" "$BASE/INDEX.md" "$BASE/SIF_TREE.txt" "$BASE/firma.db"

cat > "$BASE/README.md" << 'EOF'
# SIF - Firma Inteligencia

Estructura oficial de datos de **Strategic Intelligence Firm**.

- **Ubicación**: `/opt/sif/firma_inteligencia`
- **Propietario**: root:sif-admin
- **Gestión de permisos**: grupos Linux + ACLs

Ver documentación en el repositorio de la distro.
EOF

for mod in AML CYBERINT DUE_DILIGENCE ESG FININT GEOINT HUMINT OSINT RIESGO_PAIS SEGURIDAD_CORPORATIVA SOCMINT; do
    if [[ -d "$BASE/15_Modulos/$mod" ]]; then
        echo "# Módulo $mod - Strategic Intelligence Firm" > "$BASE/15_Modulos/$mod/README.md"
    fi
done

log "Estructura base creada correctamente en $BASE"
log "Total de directorios: $(find "$BASE" -type d | wc -l)"
echo
log "Siguiente paso: sudo bash scripts/setup-permissions.sh"
