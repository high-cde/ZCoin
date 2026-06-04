use axum::{Router, routing::get, Json};
use serde_json::json;
use crate::rpc;
use tokio::net::TcpListener;
use std::net::SocketAddr;

async fn status_handler() -> Json<serde_json::Value> {
    Json(json!({ "ok": true }))
}

pub async fn start_server() {
    let addr: SocketAddr = "0.0.0.0:8765".parse().unwrap();
    println!("[*] HighCoin RPC listening on http://{}", addr);

    let app = Router::new()
        .route("/status", get(status_handler))
        .nest("/rpc", rpc::router());

    let listener = TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
