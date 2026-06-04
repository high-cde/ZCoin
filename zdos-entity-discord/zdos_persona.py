def format_hl0_state(state):
    return (
        f"⚡ HL0 State\\n"
        f"- mode: {state.get('mode')}\\n"
        f"- last_block: {state.get('last_block')}\\n"
        f"- locks_processed: {state.get('locks_processed')}\\n"
    )

def format_alert(msg):
    return f"🚨 {msg}"
