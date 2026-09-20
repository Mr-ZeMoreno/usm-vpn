#!/bin/bash
# Desinstalador de usm-vpn (macOS / Linux).
if command -v usm-vpn >/dev/null 2>&1; then
    usm-vpn uninstall "$@"
elif [ -x "$HOME/.usm-vpn/usm-vpn" ]; then
    python3 "$HOME/.usm-vpn/usm-vpn" uninstall "$@"
else
    echo "usm-vpn no parece instalado."
fi
