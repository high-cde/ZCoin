#!/bin/bash

echo "----------------------------------------"
echo "[ZDOS] AUTOBUILD WEB — MODE: ULTRA"
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

# 2) Se index non esiste → crea
if [ ! -f "$HOME/HighCoin/index.html" ]; then
    log "index.html non trovato. Generazione automatica…"
    cat > "$HOME/HighCoin/index.html" << 'EOF'
<html><body style="background:black;color:#00ff7f;font-family:monospace;">
<h1>HIGHCOIN PORTAL — AUTO-GENERATED</h1>
</body></html>
EOF
fi

# 3) Minificazione HTML
log "Minificazione HTML…"
MINIFIED=$(sed 's/^[ \t]*//;s/[ \t]*$//' "$HOME/HighCoin/index.html" | tr -d '\n')
echo "$MINIFIED" > "$HOME/HighCoin/index.min.html"

# 4) Versioning
VERSION=$(date +%s)
cp "$HOME/HighCoin/index.min.html" "$WEBROOT/index.v$VERSION.html"
log "Versione creata: index.v$VERSION.html"

# 5) Deploy come index.html
cp "$HOME/HighCoin/index.min.html" "$WEBROOT/index.html"
log "index.html aggiornato"

# 6) Rollback automatico (mantiene solo 10 versioni)
cd "$WEBROOT"
ls -t index.v*.html | sed -e '1,10d' | xargs -r rm
log "Rollback: mantenute ultime 10 versioni"

# 7) Git update solo se serve
cd "$HOME/HighCoin"
if ! git diff --quiet; then
    git add -A
    git commit -m "ULTRA autobuild $(date '+%Y-%m-%d %H:%M:%S')"
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

log "AUTOBUILD ULTRA COMPLETATO"
echo "----------------------------------------"
