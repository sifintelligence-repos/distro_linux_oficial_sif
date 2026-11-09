#!/bin/bash
# setup-structure.sh
# Crea la estructura base de carpetas de SIF en /opt/sif/firma_inteligencia
# Réplica simplificada del árbol principal (se puede expandir con el backup completo)

set -e

BASE="/opt/sif/firma_inteligencia"

echo "Creando estructura en $BASE ..."

sudo mkdir -p "$BASE"

# Carpetas principales (según SIF_TREE y backup)
DIRS=(
  "00_GOBERNANZA_Y_COMPLIANCE"
  "01_Clientes/Clientes_Activos/00_PLANTILLA_CLIENTE"
  "02_Proyectos/00_PLANTILLA_PROYECTO/Analisis"
  "02_Proyectos/00_PLANTILLA_PROYECTO/Evidencias"
  "03_Operaciones/01_Procesos"
  "03_Operaciones/02_Procedimientos"
  "03_Operaciones/03_Flujos_Trabajo"
  "03_Operaciones/04_Control_Calidad"
  "03_Operaciones/05_Manuales"
  "04_Documentos"
  "05_Riesgos"
  "06_Fuentes"
  "07_Auditorias"
  "08_Facturacion"
  "09_Evidencias"
  "10_Plantillas/plantillas"
  "11_Reportes"
  "12_Cumplimiento"
  "14_Recursos_Humanos"
  "15_Modulos/AML/00_Manuales"
  "15_Modulos/AML/07_Casos"
  "15_Modulos/AML/08_Informes"
  "15_Modulos/AML/09_Base_Conocimiento"
  "15_Modulos/CYBERINT"
  "15_Modulos/DUE_DILIGENCE"
  "15_Modulos/ESG"
  "15_Modulos/FININT"
  "15_Modulos/GEOINT"
  "15_Modulos/HUMINT"
  "15_Modulos/ISO27001"
  "15_Modulos/LITIGATION_SUPPORT"
  "15_Modulos/OSINT"
  "15_Modulos/RIESGO_PAIS"
  "15_Modulos/SEGURIDAD_CORPORATIVA"
  "15_Modulos/SOC2"
  "15_Modulos/SOCMINT"
  "15_Modulos/CATALOGO_SERVICIOS"
  "18_Automatizacion/CLI"
  "18_Automatizacion/APIs"
  "18_Automatizacion/Agentes_IA"
  "18_Automatizacion/Dashboards"
  "18_Automatizacion/Bots"
  "22_Tecnologia/Arquitectura"
  "22_Tecnologia/Desarrollo"
  "22_Tecnologia/IA"
  "22_Tecnologia/Infraestructura"
  "22_Tecnologia/Redes"
  "22_Tecnologia/Seguridad"
  "22_Tecnologia/Servidores"
  "23_Activos_Digitales/Audio"
  "23_Activos_Digitales/Imagenes"
  "23_Activos_Digitales/Videos"
  "23_Activos_Digitales/Plantillas"
  "24_Laboratorio/Benchmarks"
  "24_Laboratorio/Dataset"
  "24_Laboratorio/Experimentos"
  "24_Laboratorio/Sandbox"
  "25_Archivado/Casos_Cerrados"
  "25_Archivado/Proyectos_Finalizados"
  "logs"
)

for d in "${DIRS[@]}"; do
  sudo mkdir -p "$BASE/$d"
done

# Archivos placeholder mínimos
sudo touch "$BASE/manifest.json" "$BASE/config.yaml" "$BASE/INDEX.md" "$BASE/SIF_TREE.txt" "$BASE/firma.db"

echo "Estructura base creada en $BASE"
echo "Siguiente paso: ejecutar setup-permissions.sh"
