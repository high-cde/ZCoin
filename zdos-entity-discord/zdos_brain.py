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
