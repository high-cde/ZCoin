use tokio::runtime::Runtime;

mod server;
mod runtime;
mod rpc;

fn main() {
    println!("[*] HighCoin Node starting...");

    let rt = Runtime::new().unwrap();

    rt.block_on(async {
        // 🔥 AVVIA IL BLOCK PRODUCER IN BACKGROUND
        tokio::spawn(async {
            runtime::start_block_producer().await;
        });

        // 🔥 AVVIA IL SERVER RPC
        server::start_server().await;
    });
}
