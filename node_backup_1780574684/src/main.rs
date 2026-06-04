mod server;
mod rpc;
mod runtime;
mod bridge;

#[tokio::main]
async fn main() {
    println!("[*] HighCoin Node starting...");
    server::start_server().await;
}
