#!/bin/bash

echo "----------------------------------------"
echo "[ZDOS] AUTOBUILD PORTALE REALE — MODE: V7"
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

# 2) Verifica portale
if [ ! -d "$HOME/HighCoin/portal" ]; then
    log "ERRORE: ~/HighCoin/portal non esiste."
    exit 1
fi

# 3) Copia portale nella webroot
log "Copia del portale…"
rsync -av --delete "$HOME/HighCoin/portal/" "$WEBROOT/portal/" >> "$LOGFILE" 2>&1
log "Portale copiato."

# 4) Inserimento automatico dei 4 moduli reali
log "Patch dei moduli reali…"

# HL0 CONSOLE REALE
cat > "$WEBROOT/portal/hl0-console.real.js" << 'EOF'
async function fetchHL0() {
  try {
    const res = await fetch("/rpc/view/hyper_universe/oracle_state");
    const json = await res.json();
    log("[HL0] state: " + JSON.stringify(json));
  } catch (e) {
    log("[HL0] error: " + e.toString());
  }
}
setInterval(fetchHL0, 2500);
fetchHL0();
EOF

# EXPLORER REALE
cat > "$WEBROOT/portal/explorer.real.js" << 'EOF'
async function snapshot() {
  try {
    const res = await fetch("/rpc/view/hyper_universe/oracle_state");
    const json = await res.json();
    log("[HL0] state: " + JSON.stringify(json));
  } catch (e) {
    log("[HL0] error: " + e.toString());
  }
}
snapshot();
EOF

# DASHBOARD REALE
cat > "$WEBROOT/portal/dashboard.real.js" << 'EOF'
async function loadDashboard() {
  try {
    const res = await fetch("/rpc/view/hyper_universe/oracle_state");
    const json = await res.json();
    document.getElementById("net-mode").textContent = json.mode || "REAL";
    document.getElementById("last-block").textContent = json.last_block;
    document.getElementById("locks").textContent = json.locks_processed;
  } catch (e) {}
}
setInterval(loadDashboard, 3000);
loadDashboard();
EOF

# Z-LANG REALE
cat > "$WEBROOT/portal/zlang.real.js" << 'EOF'
document.getElementById("btn-run").addEventListener("click", async () => {
  const code = document.getElementById("zlang-editor").value;
  const log = document.getElementById("zlang-log");
  log.innerHTML = "";
  try {
    const res = await fetch("/rpc/tx/zlang_run", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ code })
    });
    const json = await res.json();
    const div = document.createElement("div");
    div.textContent = "[Z-LANG] output: " + JSON.stringify(json);
    log.appendChild(div);
  } catch (e) {
    const div = document.createElement("div");
    div.textContent = "[Z-LANG] error: " + e.toString();
    log.appendChild(div);
  }
});
EOF

log "Moduli reali installati."

# 5) Minificazione HTML
log "Minificazione HTML…"
for file in $(find "$WEBROOT/portal" -name "*.html"); do
    MINIFIED=$(sed 's/^[ \t]*//;s/[ \t]*$//' "$file" | tr -d '\n')
    echo "$MINIFIED" > "$file"
done
log "Minificazione completata."

# 6) Versioning index
VERSION=$(date +%s)
cp "$WEBROOT/portal/index.html" "$WEBROOT/portal/index.v$VERSION.html"
log "Versione creata: index.v$VERSION.html"

# 7) Rollback (mantiene 10 versioni)
cd "$WEBROOT/portal"
ls -t index.v*.html | sed -e '1,10d' | xargs -r rm
log "Rollback completato."

# 8) Git update
cd "$HOME/HighCoin"
if ! git diff --quiet; then
    git add -A
    git commit -m "AUTOBUILD PORTALE REALE $(date '+%Y-%m-%d %H:%M:%S')"
    git push
    log "Git aggiornato."
else
    log "Nessuna modifica da committare."
fi

# 9) Reload NGINX
if command -v nginx >/dev/null 2>&1; then
    systemctl reload nginx
    log "NGINX ricaricato."
else
    log "NGINX non trovato."
fi

log "AUTOBUILD PORTALE REALE COMPLETATO."
echo "----------------------------------------"
