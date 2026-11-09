# Arquitectura - SIF Linux Distro

## Visión general

```
┌─────────────────────────────────────────┐
│           ISO Live + Instalador         │
│         (Ubuntu LTS + GNOME)            │
└────────────────┬────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│     Post-instalación / First Boot       │
│  - Crea /opt/sif/firma_inteligencia     │
│  - Crea grupos y usuarios base          │
│  - Aplica ACLs según roles              │
└────────────────┬────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│   Estructura idéntica al backup         │
│   /opt/sif/firma_inteligencia/          │
│   + permisos por grupos                 │
└─────────────────────────────────────────┘
```

## Componentes

1. **Base del sistema**
   - Ubuntu LTS (preferible 24.04 o 26.04)
   - GNOME Desktop (mínimo)
   - Sin paquetes extra de inteligencia

2. **Estructura de datos**
   - Ubicación: `/opt/sif/firma_inteligencia`
   - Réplica exacta del árbol del backup
   - Propietario: `root:sif-admin`
   - Permisos base + ACLs por rol

3. **Gestión de identidad**
   - Grupos Linux definidos en `docs/ROLES.md`
   - ACLs (`setfacl`) para control fino
   - Script de administración de usuarios

4. **Construcción**
   - `live-build` para generar la ISO
   - Configuración versionada en este repositorio

## Flujo de permisos

1. Se crean todos los grupos.
2. Se despliega la estructura de carpetas.
3. Se aplican permisos base.
4. Se aplican ACLs específicas por carpeta/módulo según el rol.
5. Los usuarios se crean y se añaden a los grupos correspondientes.

## Seguridad

- Cifrado de disco recomendado en la instalación (LUKS).
- Usuarios normales no tienen sudo por defecto (excepto sif-admin).
- Logs de auditoría en `/opt/sif/firma_inteligencia/logs`.
