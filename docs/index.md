<style>
body {
  background:#02030a;
  color:#e5e5ff;
  font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
}
h1, h2, h3 { color:#b26bff; }
a { color:#5cf2ff; }
.pulse { animation:pulse 2s infinite; }
.glitch {
  position:relative; display:inline-block; color:#fff;
  font-weight:800; letter-spacing:0.08em;
}
.glitch::before, .glitch::after {
  content:attr(data-text); position:absolute; left:0; top:0; opacity:0.7;
}
.glitch::before { color:#5cf2ff; transform:translate(2px,-2px); }
.glitch::after { color:#ff5cf2; transform:translate(-2px,2px); }
.btn-cyber {
  display:inline-block; padding:10px 22px; border:1px solid #5cf2ff;
  border-radius:4px; text-decoration:none; color:#5cf2ff;
  background:linear-gradient(90deg,rgba(92,242,255,0.1),rgba(178,107,255,0.15));
  box-shadow:0 0 12px rgba(92,242,255,0.4);
  text-transform:uppercase; font-size:0.85rem; letter-spacing:0.12em;
}
.btn-cyber:hover {
  background:linear-gradient(90deg,rgba(178,107,255,0.3),rgba(92,242,255,0.3));
}
.card {
  border:1px solid rgba(178,107,255,0.4); border-radius:8px;
  padding:16px; margin:12px 0;
  background:radial-gradient(circle at top left,rgba(178,107,255,0.18),transparent 55%);
}
.badge {
  display:inline-block; padding:3px 8px; border-radius:999px;
  border:1px solid rgba(92,242,255,0.6); font-size:0.7rem;
  text-transform:uppercase; letter-spacing:0.12em; color:#5cf2ff;
}
.countdown-box {
  margin-top:10px; padding:12px 16px; border-radius:8px;
  border:1px solid rgba(92,242,255,0.6);
  background:radial-gradient(circle at top,rgba(92,242,255,0.15),transparent 60%);
  font-size:1.4rem;
}
@keyframes pulse {
  0% { transform:scale(1); opacity:1; }
  50% { transform:scale(1.03); opacity:0.7; }
  100% { transform:scale(1); opacity:1; }
}
</style>

# <span class="glitch" data-text="HIGHCOIN x ZDOS">HIGHCOIN x ZDOS</span>
### Quantum Ecosystem — by ZDOS

HighCoin è il motore decentralizzato dell’ecosistema **ZDOS**.

[<span class="btn-cyber pulse">ENTER ZDOS</span>](https://x-zdos.it)

---

## ⏳ Quantum Activation Countdown  
### Lancio Ufficiale: **31 Ottobre 2026 — 00:00 CET**

<div class="countdown-box pulse" id="countdown">Syncing quantum clock…</div>

<script>
const target = new Date("2026-10-31T00:00:00").getTime();
setInterval(() => {
  const now = new Date().getTime();
  const diff = target - now;
  if (diff <= 0) {
    document.getElementById("countdown").innerHTML =
      "ACTIVATED • HIGHCOIN MAINNET ONLINE";
    return;
  }
  const d = Math.floor(diff / (1000*60*60*24));
  const h = Math.floor((diff % (1000*60*60*24)) / (1000*60*60));
  const m = Math.floor((diff % (1000*60*60)) / (1000*60));
  const s = Math.floor((diff % (1000*60)) / 1000);
  document.getElementById("countdown").innerHTML =
    d + " giorni • " + h + " ore • " + m + " min • " + s + " sec";
}, 1000);
</script>

---

## 🕺 Danza Quantistica di Attivazione

<div class="card">
La <b>Danza Quantistica</b> sincronizza:
<ul>
<li>clock interno</li>
<li>nodo HighCoin</li>
<li>Z‑Lang VM</li>
<li>modulo P2P</li>
<li>wallet ZDOS</li>
<li>modulo RPC</li>
</ul>
<b>SYNC → BOOT → LINK → BROADCAST → ACTIVATE</b>
</div>

---

## 🚀 Avvio Rapido HighCoin (Quickstart)

\`\`\`bash
git clone https://github.com/high-cde/HighCoin
cd HighCoin
cargo build --release
./target/release/node --network mainnet
highcoin-node-cli info
\`\`\`

---

## 🧬 Visione

HighCoin è il motore quantistico dell’intero ecosistema ZDOS.

