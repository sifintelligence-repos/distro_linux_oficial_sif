# Guía de Construcción - SIF Linux

## Requisitos en la máquina de build

- Ubuntu 24.04 o superior
- Paquetes:
  ```bash
  sudo apt update
  sudo apt install -y live-build debootstrap squashfs-tools xorriso
  ```

## Pasos iniciales

1. Clonar este repositorio.
2. Preparar la configuración de `live-build` (en desarrollo).
3. Incluir los scripts de post-instalación.
4. Generar la ISO.

## Comandos básicos (cuando esté listo)

```bash
sudo lb clean
sudo lb config --distribution noble --architectures amd64 --binary-images iso-hybrid --debian-installer live
sudo lb build
```

> La configuración exacta de live-build se irá completando en las próximas iteraciones.
