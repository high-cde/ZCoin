/*
  HighCoin Runtime RPC-like
  Espone una API tipo JSON-RPC ma in locale:
  - hc_getBlock
  - hc_getHeight
  - hc_getBalance
  - hc_sendTx
  - hc_mineBlock
*/

const HighCoinRPC = (function(){
  async function ensure() {
    await HighCoinNode.init();
  }

  async function call(method, params = []) {
    await ensure();
    switch(method) {
      case "hc_getHeight":
        return HighCoinNode.getHeight();

      case "hc_getBlock":
        return HighCoinNode.getBlockByIndex(params[0] || 0);

      case "hc_getLatestBlock":
        return HighCoinNode.getLatestBlock();

      case "hc_getChain":
        return HighCoinNode.getChain();

      case "hc_getBalance":
        return HighCoinNode.getBalance(params[0] || "");

      case "hc_sendTx":
        HighCoinNode.addTx(params[0], params[1], params[2]);
        return { status:"ok" };

      case "hc_mineBlock":
        return await HighCoinNode.mineBlock(params[0] || "miner-local", params[1] || 3);

      case "hc_getMempool":
        return HighCoinNode.getMempool();

      default:
        throw new Error("Metodo RPC sconosciuto: " + method);
    }
  }

  return { call };
})();
