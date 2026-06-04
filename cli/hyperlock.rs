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
