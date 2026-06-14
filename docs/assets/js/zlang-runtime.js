/*
  Z-Lang WASM Runtime Loader (stub)
  - Carica zlang.wasm
  - Espone API: run(code), sysInfo(), walletNew(), minerTest()
  - Quando avrai il vero WASM, sostituisci loadWasm() con la versione reale.
*/

const ZLangRuntime = (function(){
  let wasmInstance = null;

  async function loadWasm() {
    if (wasmInstance) return wasmInstance;
    // TODO: sostituire con WASM reale
    // const resp = await fetch('assets/js/zlang.wasm');
    // const buf  = await resp.arrayBuffer();
    // const { instance } = await WebAssembly.instantiate(buf, {});
    // wasmInstance = instance;
    // return wasmInstance;

    // MOCK: nessun WASM reale, solo stub
    wasmInstance = { exports: {} };
    return wasmInstance;
  }

  async function run(code) {
    await loadWasm();
    // TODO: chiamare funzione WASM reale, es: wasmInstance.exports.run(code)
    // Per ora, mock:
    if (code.trim() === "") return ">> (vuoto)";
    if (code.startsWith("print ")) {
      return code.slice(6);
    }
    if (code === "sys.info") {
      return [
        "Z-Lang Runtime: MOCK",
        "WASM: stub (zlang.wasm da collegare)",
        "Env: Browser JS + ZDOS"
      ].join("\n");
    }
    return ">> [mock] Z-Lang ha ricevuto: " + code;
  }

  async function sysInfo() {
    return run("sys.info");
  }

  async function walletNew() {
    await loadWasm();
    // TODO: delegare a WASM; per ora mock
    const pk = crypto.getRandomValues(new Uint8Array(32));
    const hexpk = Array.from(pk).map(b=>b.toString(16).padStart(2,"0")).join("");
    return {
      privateKey: hexpk,
      note: "mock key, sostituire con derivazione Z-Lang WASM"
    };
  }

  async function minerTest() {
    await loadWasm();
    // TODO: PoW via WASM; per ora mock
    return "Miner Z-Lang mock: 512 H/s (stub)";
  }

  return {
    loadWasm,
    run,
    sysInfo,
    walletNew,
    minerTest
  };
})();
