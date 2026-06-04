use serde_json::{json, Value};
use std::collections::HashMap;
use std::sync::{
    atomic::{AtomicU64, Ordering},
    Mutex,
};

lazy_static::lazy_static! {
    static ref BALANCES: Mutex<HashMap<String, u128>> = Mutex::new(HashMap::new());
    static ref NONCES: Mutex<HashMap<String, u64>> = Mutex::new(HashMap::new());
    static ref BLOCKS: Mutex<HashMap<u64, Value>> = Mutex::new(HashMap::new());
    static ref TXS: Mutex<HashMap<String, Value>> = Mutex::new(HashMap::new());
    static ref MEMPOOL: Mutex<Vec<Value>> = Mutex::new(Vec::new());
}

static BLOCK_HEIGHT: AtomicU64 = AtomicU64::new(0);
static DIFFICULTY: AtomicU64 = AtomicU64::new(0x00000FFFFFFFFFFF);

fn simple_hash(input: &str) -> u64 {
    use std::hash::{BuildHasher, Hasher};
    let state = std::collections::hash_map::RandomState::new();
    let mut h = state.build_hasher();
    h.write(input.as_bytes());
    h.finish()
}

pub fn mine(data: &str) -> (String, u64) {
    let mut nonce = 0u64;
    let diff = DIFFICULTY.load(Ordering::SeqCst);
    loop {
        let h = simple_hash(&format!("{}{}", data, nonce));
        if h < diff {
            return (format!("0x{:x}", h), nonce);
        }
        nonce += 1;
    }
}

pub fn adjust_difficulty(block_time_ms: u128) {
    let target = 2000;
    let diff = DIFFICULTY.load(Ordering::SeqCst);
    let new_diff = if block_time_ms < target {
        diff << 1
    } else {
        diff >> 1
    };
    DIFFICULTY.store(new_diff, Ordering::SeqCst);
}

pub fn get_block_height() -> u64 {
    BLOCK_HEIGHT.load(Ordering::SeqCst)
}

pub fn get_balance(addr: &str) -> u128 {
    *BALANCES.lock().unwrap().get(addr).unwrap_or(&0)
}

pub fn get_nonce(addr: &str) -> u64 {
    *NONCES.lock().unwrap().get(addr).unwrap_or(&0)
}

pub fn store_tx(hash: &str, tx: Value) {
    TXS.lock().unwrap().insert(hash.to_string(), tx);
}

pub fn get_tx(hash: &str) -> Value {
    TXS.lock().unwrap().get(hash).cloned().unwrap_or(json!({}))
}

pub fn add_to_mempool(tx: Value) {
    MEMPOOL.lock().unwrap().push(tx);
}

pub fn drain_mempool() -> Vec<Value> {
    let mut m = MEMPOOL.lock().unwrap();
    let txs = m.clone();
    m.clear();
    txs
}

pub fn store_block(height: u64, block: Value) {
    BLOCKS.lock().unwrap().insert(height, block);
}

pub fn get_block(height: u64) -> Value {
    BLOCKS
        .lock()
        .unwrap()
        .get(&height)
        .cloned()
        .unwrap_or(json!({}))
}

pub fn save_block_to_disk(height: u64, block: &Value) {
    std::fs::create_dir_all("data/blocks").ok();
    let path = format!("data/blocks/{height}.json");
    let s = serde_json::to_string_pretty(block).unwrap();
    let _ = std::fs::write(path, s);
}

pub fn load_blocks_from_disk() {
    use std::fs;
    if let Ok(entries) = fs::read_dir("data/blocks") {
        for e in entries.flatten() {
            if let Some(name) = e.file_name().to_str() {
                if name.ends_with(".json") {
                    if let Ok(h) = name.trim_end_matches(".json").parse::<u64>() {
                        if let Ok(s) = fs::read_to_string(e.path()) {
                            if let Ok(v) = serde_json::from_str::<Value>(&s) {
                                store_block(h, v);
                                BLOCK_HEIGHT.store(h + 1, Ordering::SeqCst);
                            }
                        }
                    }
                }
            }
        }
    }
}

pub fn apply_raw_tx(raw: &str) -> Result<String, String> {
    let h = simple_hash(raw);
    let hash = format!("0x{:x}", h);
    let tx = json!({ "hash": hash, "raw": raw });
    store_tx(&hash, tx.clone());
    add_to_mempool(tx);
    Ok(hash)
}

pub async fn start_block_producer() {
    use tokio::time::{sleep, Duration};
    loop {
        let start = std::time::Instant::now();

        let txs = drain_mempool();
        let height = BLOCK_HEIGHT.fetch_add(1, Ordering::SeqCst);

        let block = json!({
            "height": height,
            "timestamp": chrono::Utc::now().timestamp(),
            "txs": txs,
        });

        store_block(height, block.clone());
        save_block_to_disk(height, &block);

        let elapsed = start.elapsed().as_millis();
        adjust_difficulty(elapsed);

        sleep(Duration::from_secs(2)).await;
    }
}
