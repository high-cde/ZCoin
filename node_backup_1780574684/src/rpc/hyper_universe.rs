use serde::{Deserialize, Serialize};
use serde_json::json;
use crate::runtime::call_view;

#[derive(Serialize, Deserialize)]
pub struct Empty {}

pub async fn view_oracle_state() -> serde_json::Value {
    let state = runtime::call_view("HyperUniverse", "oracle_state", json!({}))
        .unwrap_or(json!({ "error": "view failed" }));
    state
}

pub async fn view_admin_status() -> serde_json::Value {
    let state = runtime::call_view("HyperUniverse", "admin_status", json!({}))
        .unwrap_or(json!({ "error": "view failed" }));
    state
}

// Endpoint semplificato per HyperLock events (stub: da collegare al log/event store reale)
pub async fn list_hyperlocks() -> serde_json::Value {
    // TODO: collegare a event store reale
    json!({
        "events": []
    })
}

// Marca processed lato bridge (stub)
#[derive(Deserialize)]
pub struct MarkProcessedReq {
    pub id: String,
}

pub async fn mark_processed(_req: MarkProcessedReq) -> serde_json::Value {
    // TODO: segnare processed nel DB/event store
    json!({ "ok": true })
}
