use axum::{Router, routing::{get, post}, Json};
use serde_json::Value;

mod hyper_universe;

pub fn router() -> Router {
    Router::new()
        .route("/view/hyper_universe/admin_status", post(view_admin_status))
        .route("/view/hyper_universe/oracle_state", post(view_oracle_state))
        .route("/events/hyperlock", get(list_hyperlocks))
        .route("/bridge/mark_processed", post(mark_processed))
}

async fn view_admin_status() -> Json<Value> {
    Json(hyper_universe::view_admin_status().await)
}

async fn view_oracle_state() -> Json<Value> {
    Json(hyper_universe::view_oracle_state().await)
}

async fn list_hyperlocks() -> Json<Value> {
    Json(hyper_universe::list_hyperlocks().await)
}

async fn mark_processed(
    Json(req): Json<hyper_universe::MarkProcessedReq>
) -> Json<Value> {
    Json(hyper_universe::mark_processed(req).await)
}
