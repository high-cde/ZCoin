use crate::rpc::router;
use axum::{
    extract::Path,
    routing::{get, post},
    Json, Router,
};
use serde_json::json;
use std::net::SocketAddr;
use tokio::net::TcpListener;

async fn status() -> Json<serde_json::Value> {
    Json(json!({ "ok": true }))
}

pub async fn start_server() {
    let addr: SocketAddr = "0.0.0.0:8765".parse().unwrap();
    println!("[*] HighCoin RPC listening on http://{}", addr);

    let app = Router::new()
        .route("/status", get(status))
        .route(
            "/",
            post(|Json(req): Json<serde_json::Value>| async move { Json(router::handle_rpc(req)) }),
        )
        .route(
            "/tx/{hash}",
            get(|Path(h): Path<String>| async move { Json(crate::runtime::get_tx(&h)) }),
        )
        .route(
            "/block/{height}",
            get(|Path(h): Path<u64>| async move { Json(crate::runtime::get_block(h)) }),
        )
        .route(
            "/address/{addr}",
            get(|Path(a): Path<String>| async move {
                Json(json!({ "address": a, "balance": crate::runtime::get_balance(&a) }))
            }),
        );

    let listener = TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}
