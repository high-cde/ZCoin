# HighCoin Node Installer

Installer ufficiale per un nodo HighCoin completo (RPC + META via NGINX).

## Installazione rapida

```bash
curl -sL http://5.189.180.13/install-highcoin-node.sh | bash
```

## Cosa installa

- Nodo HighCoin (systemd)
- RPC pubblico su **http://5.189.180.13:8181**
- META endpoint su **http://5.189.180.13:8090**
- Reverse proxy NGINX
- Compilazione automatica in modalità release

## Requisiti

- Ubuntu 22.04+ / 24.04+
- Accesso root

