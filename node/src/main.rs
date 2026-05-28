use node::{state::State, rpc::start_rpc};
use std::sync::{Mutex, LazyLock};

static STATE: LazyLock<State> = LazyLock::new(|| {
    State {
        height: 0,
        vm: Mutex::new(node::vm::Vm::new()),
    }
});

#[tokio::main]
async fn main() {
    start_rpc(&STATE);

    loop {
        tokio::time::sleep(std::time::Duration::from_secs(5)).await;
    }
}
