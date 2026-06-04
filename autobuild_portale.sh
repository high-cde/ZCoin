#!/bin/bash

echo "----------------------------------------"
echo "[ZDOS] AUTOBUILD PORTALE — MODE: ULTRA"
echo "----------------------------------------"

LOGFILE="/var/log/zdos-web.log"
mkdir -p /var/log

log() {
    echo "[ZDOS] $1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') — $1" >> "$LOGFILE"
}

# 1) Rileva cartella web
if [ -d "/var/www/x-zdos.it/public" ]; then
    WEBROOT="/var/www/x-zdos.it/public"
elif [ -d "/var/www/html" ]; then
    WEBROOT="/var/www/html"
else
    mkdir -p "$HOME/HighCoin/public"
    WEBROOT="$HOME/HighCoin/public"
fi

log "Cartella web rilevata: $WEBROOT"

# 2) Verifica che il portale esista
if [ ! -d "$HOME/HighCoin/portal" ]; then
    log "ERRORE: la cartella ~/HighCoin/portal non esiste."
    exit 1
fi

# 3) Copia TUTTO il portale nella webroot
log "Copia del portale in corso…"
rsync -av --delete "$HOME/HighCoin/portal/" "$WEBROOT/portal/" >> "$LOGFILE" 2>&1
log "Portale copiato."

# 4) Minificazione HTML
log "Minificazione HTML…"
for file in $(find "$WEBROOT/portal" -name "*.html"); do
    MINIFIED=$(sed 's/^[ \t]*//;s/[ \t]*$//' "$file" | tr -d '\n')
    echo "$MINIFIED" > "$file"
done
log "Minificazione completata."

# 5) Versioning (solo index)
VERSION=$(date +%s)
cp "$WEBROOT/portal/index.html" "$WEBROOT/portal/index.v$VERSION.html"
log "Versione creata: index.v$VERSION.html"

# 6) Rollback automatico (mantiene solo 10 versioni)
cd "$WEBROOT/portal"
ls -t index.v*.html | sed -e '1,10d' | xargs -r rm
log "Rollback: mantenute ultime 10 versioni"

# 7) Git update solo se serve
cd "$HOME/HighCoin"
if ! git diff --quiet; then
    git add -A
    git commit -m "ULTRA autobuild portale $(date '+%Y-%m-%d %H:%M:%S')"
    git push
    log "Git aggiornato"
else
    log "Nessuna modifica da committare"
fi

# 8) Reload NGINX
if command -v nginx >/dev/null 2>&1; then
    systemctl reload nginx
    log "NGINX ricaricato"
else
    log "NGINX non trovato"
fi

log "AUTOBUILD PORTALE COMPLETATO"
echo "----------------------------------------"
