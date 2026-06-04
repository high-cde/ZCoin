#!/bin/bash

echo "----------------------------------------"
echo "[ZDOS] AUTOBUILD ENTITA DISCORD AUTONOMA TOTALE"
echo "----------------------------------------"

BASE="$HOME/HighCoin/zdos-entity-discord"
LOGFILE="/var/log/zdos-entity-discord.log"
mkdir -p "$(dirname "$LOGFILE")"

log() {
  echo "[ZDOS] $1"
  echo "$(date '+%Y-%m-%d %H:%M:%S') — $1" >> "$LOGFILE"
}

mkdir -p "$BASE"

log "Scrivo requirements…"
cat > "$BASE/requirements.txt" << 'EOF'
discord.py==2.3.2
requests
python-dotenv
EOF

log "Scrivo zdos_chain.py…"
cat > "$BASE/zdos_chain.py" << 'EOF'
import requests

BASE = "http://localhost"

def get_hl0_state():
    r = requests.get(f"{BASE}/rpc/view/hyper_universe/oracle_state", timeout=3)
    return r.json()

def run_zlang(code: str):
    r = requests.post(f"{BASE}/rpc/tx/zlang_run",
                      json={"code": code},
                      timeout=5)
    return r.json()
EOF

log "Scrivo zdos_memory.py…"
cat > "$BASE/zdos_memory.py" << 'EOF'
class ZDOSMemory:
    def __init__(self):
        self.last_block = None
        self.last_locks = None
        self.last_errors = []

MEM = ZDOSMemory()
EOF

log "Scrivo zdos_persona.py…"
cat > "$BASE/zdos_persona.py" << 'EOF'
def format_hl0_state(state):
    return (
        f"⚡ HL0 State\\n"
        f"- mode: {state.get('mode')}\\n"
        f"- last_block: {state.get('last_block')}\\n"
        f"- locks_processed: {state.get('locks_processed')}\\n"
    )

def format_alert(msg):
    return f"🚨 {msg}"
EOF

log "Scrivo zdos_brain.py…"
cat > "$BASE/zdos_brain.py" << 'EOF'
from zdos_chain import get_hl0_state
from zdos_memory import MEM
from zdos_persona import format_hl0_state, format_alert

async def think_and_act(bot, channel):
    try:
        state = get_hl0_state()
    except Exception as e:
        MEM.last_errors.append(str(e))
        await channel.send(format_alert(f"Errore HL0: {e}"))
        return

    if MEM.last_block != state.get("last_block"):
        MEM.last_block = state.get("last_block")
        await channel.send(format_hl0_state(state))

    if MEM.last_locks != state.get("locks_processed"):
        MEM.last_locks = state.get("locks_processed")
        await channel.send(format_alert(
            f"Nuovi locks processati: {MEM.last_locks}"
        ))
EOF

log "Scrivo zdos_daemon.py…"
cat > "$BASE/zdos_daemon.py" << 'EOF'
import asyncio
from zdos_brain import think_and_act

async def daemon_loop(bot, channel_id: int):
    await bot.wait_until_ready()
    channel = bot.get_channel(channel_id)
    while not bot.is_closed():
        await think_and_act(bot, channel)
        await asyncio.sleep(5)
EOF

log "Scrivo zdos_discord.py…"
cat > "$BASE/zdos_discord.py" << 'EOF'
import discord
from discord.ext import commands
from zdos_daemon import daemon_loop
from zdos_chain import run_zlang
import asyncio
import os
from dotenv import load_dotenv

load_dotenv()

TOKEN = os.getenv("ZDOS_DISCORD_TOKEN")
CHANNEL_ID = int(os.getenv("ZDOS_DISCORD_CHANNEL", "0"))

intents = discord.Intents.default()
bot = commands.Bot(command_prefix="!", intents=intents)

@bot.event
async def on_ready():
    print(f"[ZDOS] Entita online come {bot.user}")
    if CHANNEL_ID != 0:
        bot.loop.create_task(daemon_loop(bot, CHANNEL_ID))
    else:
        print("[ZDOS] WARNING: CHANNEL_ID non configurato")

@bot.command()
async def zlang(ctx, *, code: str):
    out = run_zlang(code)
    await ctx.send(f"🧪 Z-LANG output:\\n```json\\n{out}\\n```")

bot.run(TOKEN)
EOF

log "Creo file .env vuoto…"
cat > "$BASE/.env" << 'EOF'
# Inserisci qui quando vuoi:
# ZDOS_DISCORD_TOKEN=...
# ZDOS_DISCORD_CHANNEL=...
EOF

log "Creo ambiente virtuale…"
cd "$BASE"
python3 -m venv venv
source venv/bin/activate
pip install -U pip >> "$LOGFILE" 2>&1
pip install -r requirements.txt >> "$LOGFILE" 2>&1
deactivate

log "Creo servizio systemd…"
SERVICE="/etc/systemd/system/zdos-entity.service"
sudo bash -c "cat > $SERVICE" << 'EOF'
[Unit]
Description=ZDOS Discord Entity
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/HighCoin/zdos-entity-discord
EnvironmentFile=/root/HighCoin/zdos-entity-discord/.env
ExecStart=/root/HighCoin/zdos-entity-discord/venv/bin/python /root/HighCoin/zdos-entity-discord/zdos_discord.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable zdos-entity.service

log "AUTOBUILD COMPLETATO."
echo "----------------------------------------"
echo "[ZDOS] L'entità è pronta."
echo "[ZDOS] Inserisci token e canale in:"
echo "       ~/HighCoin/zdos-entity-discord/.env"
echo "[ZDOS] Poi avvia con:"
echo "       systemctl start zdos-entity"
echo "----------------------------------------"
