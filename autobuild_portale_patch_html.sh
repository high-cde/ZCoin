#!/bin/bash

echo "----------------------------------------"
echo "[ZDOS] AUTOBUILD PORTALE REALE + PATCH HTML"
echo "----------------------------------------"

LOGFILE="/var/log/zdos-web.log"
mkdir -p /var/log

log() {
    echo "[ZDOS] $1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') — $1" >> "$LOGFILE"
}

# Webroot
if [ -d "/var/www/x-zdos.it/public" ]; then
    WEBROOT="/var/www/x-zdos.it/public"
else
    WEBROOT="/var/www/html"
fi

PORTAL="$WEBROOT/portal"

log "Webroot: $WEBROOT"

if [ ! -d "$HOME/HighCoin/portal" ]; then
    log "ERRORE: ~/HighCoin/portal non esiste."
    exit 1
fi

log "Copia portale…"
rsync -av --delete "$HOME/HighCoin/portal/" "$PORTAL/" >> "$LOGFILE" 2>&1
log "Portale copiato."

# JS reali
log "Scrittura moduli reali…"

cat > "$PORTAL/hl0-console.real.js" << 'EOF'
function log(line) {
  const LOG = document.getElementById("hl0-log");
  const div = document.createElement("div");
  div.textContent = line;
  LOG.appendChild(div);
  LOG.scrollTop = LOG.scrollHeight;
}
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
document.getElementById("btn-lock").addEventListener("click", async () => {
  try {
    const res = await fetch("/rpc/tx/hyperlock", { method: "POST" });
    const json = await res.json();
    log("[HL0] hyperlock: " + JSON.stringify(json));
  } catch (e) {
    log("[HL0] error: " + e.toString());
  }
});
EOF

cat > "$PORTAL/explorer.real.js" << 'EOF'
function log(line) {
  const LOG = document.getElementById("explorer-log");
  const div = document.createElement("div");
  div.textContent = line;
  LOG.appendChild(div);
  LOG.scrollTop = LOG.scrollHeight;
}
async function snapshot() {
  try {
    const res = await fetch("/rpc/view/hyper_universe/oracle_state");
    const json = await res.json();
    log("[HL0] state: " + JSON.stringify(json));
  } catch (e) {
    log("[HL0] error: " + e.toString());
  }
}
document.getElementById("btn-refresh").addEventListener("click", snapshot);
snapshot();
EOF

cat > "$PORTAL/dashboard.real.js" << 'EOF'
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

cat > "$PORTAL/zlang.real.js" << 'EOF'
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

log "Moduli reali scritti."

# Patch HTML helper
patch_html() {
  local file="$1"
  local script="$2"

  if grep -q "$script" "$file" 2>/dev/null; then
    log "Già patchato: $(basename "$file")"
    return
  fi

  log "Patch HTML: $(basename "$file") → $script"
  tmp="${file}.tmp"
  awk -v s="$script" '
    /<\/body>/ {
      print "  <script src=\"" s "\"></script>"
    }
    { print }
  ' "$file" > "$tmp" && mv "$tmp" "$file"
}

# Patch specifici
[ -f "$PORTAL/hl0-console.html" ] && patch_html "$PORTAL/hl0-console.html" "hl0-console.real.js"
[ -f "$PORTAL/explorer.html" ]     && patch_html "$PORTAL/explorer.html"     "explorer.real.js"
[ -f "$PORTAL/dashboard.html" ]    && patch_html "$PORTAL/dashboard.html"    "dashboard.real.js"
[ -f "$PORTAL/zlang-playground.html" ] && patch_html "$PORTAL/zlang-playground.html" "zlang.real.js"

# Minificazione HTML
log "Minificazione HTML…"
for file in $(find "$PORTAL" -name "*.html"); do
    MINIFIED=$(sed 's/^[ \t]*//;s/[ \t]*$//' "$file" | tr -d '\n')
    echo "$MINIFIED" > "$file"
done
log "Minificazione completata."

# Versioning index
VERSION=$(date +%s)
cp "$PORTAL/index.html" "$PORTAL/index.v$VERSION.html"
log "Versione creata: index.v$VERSION.html"

cd "$PORTAL"
ls -t index.v*.html | sed -e '1,10d' | xargs -r rm
log "Rollback versioni vecchie completato."

# Reload NGINX
if command -v nginx >/dev/null 2>&1; then
    systemctl reload nginx
    log "NGINX ricaricato."
fi

log "AUTOBUILD PORTALE REALE + PATCH HTML COMPLETATO."
echo "----------------------------------------"
