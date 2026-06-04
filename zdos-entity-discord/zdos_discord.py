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
