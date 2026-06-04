use serde::{Deserialize, Serialize};
use serde_json::{json, Value};
use crate::runtime::call_view;

#[derive(Serialize, Deserialize)]
pub struct Empty {}

#[derive(Deserialize)]
pub struct MarkProcessedReq {
    pub id: String,
}

pub async fn view_oracle_state() -> Value {
    call_view("HyperUniverse", "oracle_state", json!({}))
        .unwrap_or(json!({ "error": "view failed" }))
}

pub async fn view_admin_status() -> Value {
    call_view("HyperUniverse", "admin_status", json!({}))
        .unwrap_or(json!({ "error": "view failed" }))
}

pub async fn list_hyperlocks() -> Value {
    // TODO: collegare a event store reale
    json!({ "events": [] })
}

pub async fn mark_processed(_req: MarkProcessedReq) -> Value {
    // TODO: segnare processed nel DB/event store
    json!({ "ok": true })
}
