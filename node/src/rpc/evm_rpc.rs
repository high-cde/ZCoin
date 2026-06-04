use serde_json::{json, Value};

pub fn handle(method: &str, req: &Value) -> Value {
    let id = req["id"].clone();

    match method {
        "eth_chainId" => json!({ "jsonrpc": "2.0", "id": id, "result": "0x270f" }),

        "eth_blockNumber" => json!({
            "jsonrpc": "2.0",
            "id": id,
            "result": format!("0x{:x}", crate::runtime::get_block_height())
        }),

        "eth_getBalance" => {
            let a = req["params"][0].as_str().unwrap_or("");
            json!({ "jsonrpc": "2.0", "id": id,
                "result": format!("0x{:x}", crate::runtime::get_balance(a)) })
        },

        "eth_getTransactionCount" => {
            let a = req["params"][0].as_str().unwrap_or("");
            json!({ "jsonrpc": "2.0", "id": id,
                "result": format!("0x{:x}", crate::runtime::get_nonce(a)) })
        },

        "eth_sendRawTransaction" => {
            let raw = req["params"][0].as_str().unwrap_or("");
            match crate::runtime::apply_raw_tx(raw) {
                Ok(h) => json!({ "jsonrpc": "2.0", "id": id, "result": h }),
                Err(e) => json!({ "jsonrpc": "2.0", "id": id,
                    "error": { "code": -32000, "message": e }})
            }
        },

        "high_mine" => {
            let data = req["params"][0].as_str().unwrap_or("");
            let (h, n) = crate::runtime::mine(data);
            json!({ "jsonrpc": "2.0", "id": id, "result": { "hash": h, "nonce": n }})
        },

        _ => json!({ "jsonrpc": "2.0", "id": id,
            "error": { "code": -32601, "message": "Method not found" }})
    }
}
