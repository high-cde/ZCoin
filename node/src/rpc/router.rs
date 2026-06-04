use serde_json::Value;
use crate::rpc::evm_rpc;

pub fn handle_rpc(req: Value) -> Value {
    let m = req["method"].as_str().unwrap_or("");
    evm_rpc::handle(m, &req)
}
