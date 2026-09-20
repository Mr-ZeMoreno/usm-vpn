# usm-vpn

Cliente de línea de comandos para la **VPN SSL de la USM** (WatchGuard Fireware + OpenVPN, login SAML/Entra ID).
Alternativa ligera y sin bugs al cliente oficial: **login SAML, conectar, desconectar limpio, estado**.
Funciona en **macOS, Linux y Windows**.

## ⚠️ Seguridad — lee esto primero
- Este paquete **no** incluye certificados ni credenciales de nadie.
- Cada usuario usa **su propio** perfil (`.ovpn` + certificados) de **su** cuenta USM.
- **Nunca** compartas tu carpeta `~/.usm-vpn/profile/` ni tu `client.pem` (es tu clave privada).

## Requisitos
1. **Python 3** (macOS trae `python3`; Linux normalmente también; en Windows instálalo desde python.org y marca "Add to PATH").
2. **OpenVPN**:
   - macOS: `brew install openvpn` (o se usa el que ya trae WatchGuard).
   - Linux: `sudo apt install openvpn` / `sudo dnf install openvpn`.
   - Windows: `winget install OpenVPN.OpenVPN`.
3. **Tu perfil USM** (`.ovpn` + certificados). Si tienes el cliente WatchGuard instalado y ya conectaste una vez, `setup` lo detecta solo. Si no, expórtalo del portal y pásalo con `--profile`.

## Instalación
**macOS / Linux:**
```bash
./install.sh
usm-vpn setup
```
**Windows** (PowerShell/CMD como Administrador):
```bat
python usm-vpn setup
```
(usa `usm-vpn.cmd` como atajo)

## Uso
```
usm-vpn connect        Login SAML (abre el navegador, pega la URL de éxito) y conecta
usm-vpn connect --gui  (solo macOS) ventana de login que captura el token sola
usm-vpn disconnect     Cierra el túnel de forma limpia (SIGTERM + barrido de restos)
usm-vpn reconnect      Desconecta y vuelve a conectar
usm-vpn clean          Cierre de emergencia: mata cualquier túnel huérfano y limpia rutas
usm-vpn status         ¿Estás conectado? IP asignada
usm-vpn info           Configuración detectada y notas por SO
usm-vpn setup          Vuelve a preparar el perfil
```

### Cómo es el login
1. `usm-vpn connect` abre tu navegador en el login de la USM.
2. Haces tu **MFA** normal (Microsoft/Entra ID).
3. Llegas a una página de éxito: **copia la URL** de la barra de direcciones (contiene `token=`) y **pégala** en la terminal.
4. Se levanta el túnel. En macOS puedes evitar el copiar/pegar con `--gui`.

> El token es de un solo uso: cada conexión necesita un login nuevo (así es SAML).

## Notas
- `connect`/`disconnect` requieren privilegios (sudo en macOS/Linux, Administrador en Windows) porque OpenVPN crea la interfaz de red.
- **DNS interno**: en algunos sistemas OpenVPN no fija el DNS del campus automáticamente. Si resuelves IPs pero no nombres internos, dilo y se añade.
