use axum::{Router, routing::{get, post}, Json};
use serde_json::json;
use crate::rpc;

pub async fn start_server() {
    let app = Router::new()
        .route("/status", get(|| async { json!({"ok": true}) }))
        .nest("/rpc", rpc::router());

    let addr = "0.0.0.0:8765".parse().unwrap();
    println!("[*] HighCoin RPC listening on http://{}", addr);

    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await
        .unwrap();
}
