use serde_json::Value;

/// Wrapper minimale per chiamare funzioni view Z-Lang
pub fn call_view(module: &str, func: &str, args: Value) -> Result<Value, String> {
    Ok(serde_json::json!({
        "module": module,
        "function": func,
        "args": args,
        "status": "stub"
    }))
}
