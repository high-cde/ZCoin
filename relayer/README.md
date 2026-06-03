# HighCoin → DSN Relayer

Questo relayer:
- legge i BridgeLock da HighCoin
- invia DSN su Polygon
- marca i lock come processed

## Avvio
cd relayer
cp .env.example .env
nano .env
npm install ethers node-fetch dotenv
node relayer.js

