import 'dotenv/config';
import fetch from "node-fetch";
import { ethers } from "ethers";

const HIGHCOIN_RPC = process.env.HIGHCOIN_RPC;
const POLYGON_RPC  = process.env.POLYGON_RPC;
const DSN_CONTRACT = process.env.DSN_CONTRACT;
const RELAYER_PK   = process.env.RELAYER_PK;

const abi = [
  "function transfer(address to, uint256 amount) public returns (bool)"
];

async function getBridgeLocks() {
  const res = await fetch(HIGHCOIN_RPC + "/bridge/locks");
  return await res.json();
}

async function main() {
  console.log("[*] Relayer DSN avviato");

  const provider = new ethers.JsonRpcProvider(POLYGON_RPC);
  const wallet   = new ethers.Wallet(RELAYER_PK, provider);
  const dsn      = new ethers.Contract(DSN_CONTRACT, abi, wallet);

  while (true) {
    try {
      const locks = await getBridgeLocks();

      for (const lock of locks) {
        if (lock.processed) continue;

        console.log("[*] Nuovo lock:", lock.id);

        const tx = await dsn.transfer(lock.dest_addr, lock.amount);
        await tx.wait();

        console.log("[+] DSN inviati a", lock.dest_addr);

        await fetch(HIGHCOIN_RPC + "/bridge/mark_processed", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ id: lock.id })
        });
      }
    } catch (e) {
      console.error("[ERR]", e);
    }

    await new Promise(r => setTimeout(r, 3000));
  }
}

main();
