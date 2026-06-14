/*
  HighCoin Node (client-side, mock ma operativo)
  - In-memory blockchain
  - Balances
  - Simple PoW (hash di JSON + nonce)
*/

const HighCoinNode = (function(){
  let chain = [];
  let mempool = [];
  let balances = {};

  function sha256(str) {
    const enc = new TextEncoder().encode(str);
    return crypto.subtle.digest("SHA-256", enc).then(buf =>
      Array.from(new Uint8Array(buf)).map(b=>b.toString(16).padStart(2,"0")).join("")
    );
  }

  async function init() {
    if (chain.length > 0) return;
    const genesis = {
      index:0,
      prevHash:"0".repeat(64),
      timestamp:Date.now(),
      nonce:0,
      txs:[],
    };
    const hash = await sha256(JSON.stringify(genesis));
    genesis.hash = hash;
    chain.push(genesis);
  }

  function getHeight() {
    return chain.length - 1;
  }

  function getLatestBlock() {
    return chain[chain.length - 1] || null;
  }

  function getBlockByIndex(i) {
    return chain[i] || null;
  }

  function getBalance(addr) {
    return balances[addr] || 0;
  }

  function addTx(from, to, amount) {
    mempool.push({ from, to, amount, ts:Date.now() });
  }

  async function mineBlock(minerAddress, difficulty = 3) {
    await init();
    const prev = getLatestBlock();
    const block = {
      index: prev.index + 1,
      prevHash: prev.hash,
      timestamp: Date.now(),
      nonce: 0,
      txs: mempool.slice(),
      miner: minerAddress
    };

    const targetPrefix = "0".repeat(difficulty);
    let hash;
    while (true) {
      hash = await sha256(JSON.stringify(block));
      if (hash.startsWith(targetPrefix)) break;
      block.nonce++;
    }
    block.hash = hash;

    // apply txs
    mempool.forEach(tx => {
      balances[tx.from] = (balances[tx.from] || 0) - tx.amount;
      balances[tx.to]   = (balances[tx.to]   || 0) + tx.amount;
    });
    // reward
    balances[minerAddress] = (balances[minerAddress] || 0) + 50;

    mempool = [];
    chain.push(block);
    return block;
  }

  function getMempool() {
    return mempool.slice();
  }

  function getChain() {
    return chain.slice();
  }

  return {
    init,
    getHeight,
    getLatestBlock,
    getBlockByIndex,
    getBalance,
    addTx,
    mineBlock,
    getMempool,
    getChain
  };
})();
