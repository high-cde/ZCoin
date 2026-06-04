mod runtime;
mod rpc;
mod bridge;
mod server;

#[tokio::main]
async fn main() {
    println!("[*] HighCoin Node starting...");
    server::start_server().await;
}
