#!/bin/bash
# Instalador de usm-vpn para macOS / Linux.
set -e
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RT="$HOME/.usm-vpn"
mkdir -p "$RT"
cp "$SRC/usm-vpn" "$RT/usm-vpn"; chmod +x "$RT/usm-vpn"
[ -f "$SRC/saml-login.swift" ] && cp "$SRC/saml-login.swift" "$RT/"   # modo --gui (solo Mac)

# enlazar en el PATH
if [ -w /usr/local/bin ] || sudo -n true 2>/dev/null; then
    sudo ln -sf "$RT/usm-vpn" /usr/local/bin/usm-vpn && echo "Enlazado: /usr/local/bin/usm-vpn"
else
    mkdir -p "$HOME/.local/bin"; ln -sf "$RT/usm-vpn" "$HOME/.local/bin/usm-vpn"
    echo "Enlazado en ~/.local/bin (asegurate de tenerlo en el PATH)"
fi
echo
echo "Ahora ejecuta:  usm-vpn setup     y luego:  usm-vpn connect"
