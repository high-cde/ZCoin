# HighCoin ↔ DSN (Polygon) Bridge

Questo modulo definisce il layer ZLang `bridge.dsn.zlang` che:

- registra lock di HGC on-chain
- produce un `BridgeLock` con:
  - `id`
  - `sender`
  - `dest_chain` (Polygon/ETH/BSC)
  - `dest_addr` (address EVM)
  - `amount`
  - `nonce`
  - `ts`

## Flow lato HighCoin

1. Il wallet costruisce una tx `bridge_lock` con:
   - `dest_chain` = 137 (Polygon, DSN nativo)
   - `dest_addr`  = address EVM che riceverà $DSN
   - `amount`     = HGC da bloccare
   - `nonce`      = contatore per address

2. `bridge_lock_tx(tx)` viene chiamato dal validator / tx-apply:
   - valida i campi
   - costruisce `BridgeLock`
   - lo scrive in storage / emette event
   - blocca/burna HGC lato HighCoin

3. Un relayer legge i `BridgeLock` da HighCoin e:
   - chiama il contratto DSN su Polygon
   - trasferisce/minta $DSN all'address `dest_addr`
   - opzionale: scrive proof per future `bridge_unlock_proof`.

## Compatibilità multi-chain

Il campo `dest_chain` è pensato per:

- 137 → Polygon ($DSN nativo)
- 1   → Ethereum
- 56  → BSC

Lo stesso schema può essere riusato per altri wrapped token o bridge.

