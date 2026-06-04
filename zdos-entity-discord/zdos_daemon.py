import asyncio
from zdos_brain import think_and_act

async def daemon_loop(bot, channel_id: int):
    await bot.wait_until_ready()
    channel = bot.get_channel(channel_id)
    while not bot.is_closed():
        await think_and_act(bot, channel)
        await asyncio.sleep(5)
