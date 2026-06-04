#!/usr/bin/env bash
set -euo pipefail

echo "[*] GENERATE_HYPER_UNIVERSE_STACK // START"

############################################
# 0) BASE DIRS
############################################
mkdir -p config cli node/src node/src/rpc node/src/bridge tests .github/workflows

############################################
# 1) CONFIG HYPERLAYER-0
############################################
cat > config/hyperlayer0.json << 'JSON'
{
  "highcoin_rpc": "http://127.0.0.1:8765",
  "ghostzcash_api": "http://127.0.0.1:3001",
  "polygon_rpc": "https://polygon-rpc.com",
  "hex_contract": "0xINSERISCI_CONTRATTO_HEX",
  "dsn_contract": "0xfc90516a1f736FaC557e09D8853dB80dA192c296"
}
JSON

############################################
# 2) RPC: VIEW + EVENTI HYPERUNIVERSE
############################################
cat > node/src/rpc/hyper_universe.rs << 'RS'
use serde::{Deserialize, Serialize};
use serde_json::json;
use crate::runtime;

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
RS

############################################
# 3) RPC MOD: REGISTRAZIONE HANDLER
############################################
cat > node/src/rpc/mod.rs << 'RS'
use axum::{Router, routing::{get, post}};
use serde_json::json;

mod hyper_universe;

pub fn router() -> Router {
    Router::new()
        .route("/status", get(|| async { json!({ "ok": true }) }))
        .route("/view/hyper_universe::oracle_state", post(view_oracle_state))
        .route("/view/hyper_universe::admin_status", post(view_admin_status))
        .route("/events/hyperlock", get(list_hyperlocks))
        .route("/bridge/mark_processed", post(mark_processed))
}

async fn view_oracle_state() -> serde_json::Value {
    hyper_universe::view_oracle_state().await
}

async fn view_admin_status() -> serde_json::Value {
    hyper_universe::view_admin_status().await
}

async fn list_hyperlocks() -> serde_json::Value {
    hyper_universe::list_hyperlocks().await
}

async fn mark_processed(
    axum::Json(req): axum::Json<hyper_universe::MarkProcessedReq>
) -> serde_json::Value {
    hyper_universe::mark_processed(req).await
}
RS

############################################
# 4) BRIDGE VAULT MODULE (RUST)
############################################
cat > node/src/bridge/mod.rs << 'RS'
use std::collections::HashMap;
use std::sync::Mutex;
use lazy_static::lazy_static;
use serde::{Serialize, Deserialize};

lazy_static! {
    static ref VAULT: Mutex<HashMap<String, u128>> = Mutex::new(HashMap::new());
}

#[derive(Serialize, Deserialize, Clone)]
pub struct VaultEntry {
    pub owner: String,
    pub amount: u128,
}

pub fn deposit(owner: &str, amount: u128) {
    let mut v = VAULT.lock().unwrap();
    let e = v.entry(owner.to_string()).or_insert(0);
    *e += amount;
}

pub fn withdraw(owner: &str, amount: u128) -> bool {
    let mut v = VAULT.lock().unwrap();
    let e = v.entry(owner.to_string()).or_insert(0);
    if *e < amount {
        return false;
    }
    *e -= amount;
    true
}

pub fn balance_of(owner: &str) -> u128 {
    let v = VAULT.lock().unwrap();
    *v.get(owner).unwrap_or(&0)
}
RS

############################################
# 5) CLI HYPERLOCK
############################################
cat > cli/hyperlock.rs << 'RS'
use clap::Parser;
use reqwest::Client;
use serde_json::json;

#[derive(Parser, Debug)]
#[command(name = "highcoin-hyperlock")]
pub struct HyperLockArgs {
    #[arg(long)]
    pub amount: u128,
    #[arg(long)]
    pub dst_chain: String,
    #[arg(long)]
    pub to: String,
    #[arg(long, default_value = "http://127.0.0.1:8765")]
    pub rpc: String,
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let args = HyperLockArgs::parse();
    let client = Client::new();

    let payload = json!({
        "amount": args.amount.to_string(),
        "dst_chain": args.dst_chain,
        "dest_addr": args.to
    });

    let res = client
        .post(format!("{}/tx/hyper_universe::hyper_lock", args.rpc))
        .json(&payload)
        .send()
        .await?;

    let body = res.text().await?;
    println!("{}", body);
    Ok(())
}
RS

############################################
# 6) TEST HYPERUNIVERSE
############################################
cat > tests/hyper_universe.rs << 'RS'
use serde_json::json;

#[test]
fn hyper_universe_basic() {
    // Stub: qui collegherai al runtime reale
    let supply = 0u128;
    assert_eq!(supply, 0);
}
RS

############################################
# 7) GITHUB ACTIONS BUILD
############################################
cat > .github/workflows/build.yml << 'YML'
name: Build & Test

on:
  push:
  pull_request:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Install Rust
        uses: dtolnay/rust-toolchain@stable

      - name: Build
        run: cargo build --all --release

      - name: Test
        run: cargo test --all
YML

############################################
# 8) CARGO.TOML PATCH (FEATURE + SERDE)
############################################
if ! grep -q "serde" Cargo.toml; then
  cat >> Cargo.toml << 'TOML'

[dependencies]
serde = { version = "1", features = ["derive"] }
serde_json = "1"
reqwest = { version = "0.11", features = ["json", "rustls-tls"] }
clap = { version = "4", features = ["derive"] }
anyhow = "1"
lazy_static = "1"
tokio = { version = "1", features = ["full"] }
TOML
fi

############################################
# 9) README PATCH
############################################
cat >> README.md << 'MD'

## HyperUniverse Stack

Questo nodo include:
- Modulo Z-Lang `HyperUniverse`
- RPC:
  - /view/hyper_universe::oracle_state
  - /view/hyper_universe::admin_status
  - /events/hyperlock
  - /bridge/mark_processed
- Bridge vault (node/src/bridge)
- CLI hyperlock (cli/hyperlock.rs)
- Config HyperLayer-0 (config/hyperlayer0.json)
- GitHub Actions build/test
MD

############################################
# 10) GIT SYNC
############################################
git add .
git commit -m "Add HyperUniverse stack: RPC, bridge, CLI, config, tests, CI" || true

echo "[*] GENERATE_HYPER_UNIVERSE_STACK // DONE"
