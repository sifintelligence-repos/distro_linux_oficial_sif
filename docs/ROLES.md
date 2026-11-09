# Roles y Permisos - SIF Linux

## Principios

- Permisos a nivel de sistema de archivos usando **grupos Linux + ACLs**.
- Estructura principal en `/opt/sif/firma_inteligencia`.
- Grupo `sif-admin` tiene acceso total.
- Cada rol tiene un grupo principal.
- Los usuarios pueden pertenecer a varios grupos según necesidad.
- Clasificaciones de documentos (PUBLICO, INTERNO, CONFIDENCIAL, RESTRINGIDO) se refuerzan con ACLs donde sea necesario.

## Roles Ejecutivos y Dirección

| Grupo | Descripción | Acceso principal |
|-------|-------------|------------------|
| `sif-direccion` | Dirección General | Total (hereda de sif-admin) |
| `sif-cto` | Chief Technology Officer | Tecnología, Desarrollo, Seguridad, Infraestructura |
| `sif-cfo` | Chief Financial Officer | Finanzas, Facturación, Presupuestos, Administración |
| `sif-coo` | Chief Operating Officer | Operaciones, Proyectos, Calidad |

## Roles Técnicos / Desarrollo

| Grupo | Descripción | Acceso principal |
|-------|-------------|------------------|
| `sif-desarrolladores` | Desarrolladores (Full Stack, móviles, multiplataforma) | 22_Tecnologia/Desarrollo, 18_Automatizacion |
| `sif-kernel` | Programadores de kernel / sistemas (C/Rust) | Tecnología de bajo nivel, Laboratorio |
| `sif-hardware` | Ingenieros de integración de hardware | Tecnología/Infraestructura, Laboratorio |
| `sif-qa` | Ingenieros de automatización de pruebas | Laboratorio, Control de Calidad |

## Roles de Inteligencia y Análisis

| Grupo | Módulo / Área | Acceso principal |
|-------|---------------|------------------|
| `sif-osint` | OSINT | 15_Modulos/OSINT |
| `sif-finint` | FININT | 15_Modulos/FININT |
| `sif-geoint` | GEOINT | 15_Modulos/GEOINT |
| `sif-cyberint` | CYBERINT | 15_Modulos/CYBERINT |
| `sif-socmint` | SOCMINT | 15_Modulos/SOCMINT |
| `sif-humint` | HUMINT | 15_Modulos/HUMINT |
| `sif-due-diligence` | Due Diligence | 15_Modulos/DUE_DILIGENCE |
| `sif-aml` | AML | 15_Modulos/AML |
| `sif-esg` | ESG | 15_Modulos/ESG |
| `sif-riesgo-pais` | Riesgo País | 15_Modulos/RIESGO_PAIS |
| `sif-seguridad-corp` | Seguridad Corporativa | 15_Modulos/SEGURIDAD_CORPORATIVA |
| `sif-analistas` | Analistas generales | Módulos de inteligencia + Proyectos asignados |

## Roles Operativos y Administrativos

| Grupo | Descripción | Acceso principal |
|-------|-------------|------------------|
| `sif-operaciones` | Operaciones | 03_Operaciones, 02_Proyectos |
| `sif-finanzas` | Finanzas y Facturación | 08_Facturacion, 14_Recursos_Humanos (parcial) |
| `sif-rrhh` | Recursos Humanos | 14_Recursos_Humanos |
| `sif-auditor` | Auditoría y Cumplimiento | 07_Auditorias, 12_Cumplimiento, 00_GOBERNANZA_Y_COMPLIANCE |
| `sif-comercial` | Comercial / Closer de ventas | 01_Clientes, Proyectos comerciales |
| `sif-marketing` | Marketing y Contenido | Activos digitales, Academia |
| `sif-academia` | Docentes / Academia | 23_Activos_Digitales, materiales de formación |

## Roles Especiales

| Grupo | Descripción | Acceso |
|-------|-------------|--------|
| `sif-admin` | Administradores del sistema | Acceso total |
| `sif-clientes` | Clientes externos | Solo lectura limitada a carpetas específicas de su proyecto (se asigna por ACL individual) |
| `sif-readonly` | Solo lectura general (para ciertos roles) | Lectura en áreas no sensibles |

## Notas de implementación

- Al crear un usuario se le asigna su grupo principal y grupos secundarios.
- Las ACLs se aplican recursivamente en la estructura `/opt/sif/firma_inteligencia`.
- Los módulos sensibles (CONFIDENCIAL / RESTRINGIDO) tienen permisos más estrictos.
- Script de gestión: `scripts/manage-users.sh` (por implementar).
