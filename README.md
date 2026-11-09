# SIF Linux Official Distribution

Distro Linux oficial de **Strategic Intelligence Firm (SIF)**.

## Objetivo

Crear una distribución Linux (ISO Live + instalable) basada en Ubuntu LTS, con:

- Interfaz GNOME
- Estructura de carpetas idéntica al sistema operativo de la firma (`firma_inteligencia`)
- Gestión de usuarios y permisos por roles a nivel de sistema (grupos Linux + ACLs)
- Sistema limpio (sin herramientas de inteligencia preinstaladas; cada usuario instala lo que necesita)
- Ubicación de la estructura: `/opt/sif/firma_inteligencia`

## Base

- Ubuntu LTS (24.04 o 26.04)
- Arquitectura: amd64
- Herramienta de construcción: `live-build`

## Estado

En desarrollo inicial.

## Roles principales

Ver `docs/ROLES.md` para la lista completa de roles y permisos.

## Construcción

Ver `docs/BUILD.md`.
