use crate::rpc::evm_rpc;
use serde_json::Value;

pub fn handle_rpc(req: Value) -> Value {
    let m = req["method"].as_str().unwrap_or("");
    evm_rpc::handle(m, &req)
}
