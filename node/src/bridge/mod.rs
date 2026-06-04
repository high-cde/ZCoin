use std::collections::HashMap;
use std::sync::Mutex;
use lazy_static::lazy_static;

lazy_static! {
    static ref VAULT: Mutex<HashMap<String, u128>> = Mutex::new(HashMap::new());
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
