use serde_json::Value;

pub struct Empty {}
pub struct MarkProcessedReq {
    pub id: String,
}

pub async fn view_oracle_state() -> Value {
    Value::Null
}
pub async fn view_admin_status() -> Value {
    Value::Null
}
pub async fn list_hyperlocks() -> Value {
    Value::Null
}
pub async fn mark_processed(_req: MarkProcessedReq) -> Value {
    Value::Null
}
