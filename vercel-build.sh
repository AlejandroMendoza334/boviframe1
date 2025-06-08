#!/usr/bin/env bash
set -e

# 1) Instalar utilidades básicas
apt-get update -y && apt-get install -y git wget unzip xz-utils

# 2) Descargar el SDK de Flutter (versión estable)
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.13.8-stable.tar.xz
tar xf flutter_linux_3.13.8-stable.tar.xz
export PATH="$PWD/flutter/bin:$PATH"

# 3) (Opcional) Aceptar licencias si el build lo pide
yes | flutter doctor --android-licenses || true

# 4) Asegurar canal estable y habilitar web
flutter channel stable
flutter upgrade
flutter config --enable-web

# 5) Descargar dependencias de tu proyecto Flutter
flutter pub get

# 6) Compilar para Web en modo release
flutter build web --release
