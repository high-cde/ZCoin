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
