use tiny_http::{Server, Response};
use serde_json::json;
use crate::state::State;

pub fn start_rpc(state: &'static State) {
    let server = Server::http("0.0.0.0:8080").unwrap();

    std::thread::spawn(move || {
        for req in server.incoming_requests() {
            let response = json!({
                "height": state.height,
                "last_value": state.vm.lock().unwrap().last_value
            });

            let resp = Response::from_string(response.to_string());
            req.respond(resp).unwrap();
        }
    });
}
