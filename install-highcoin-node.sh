#!/bin/bash
set -e

IP=$(curl -s https://ipinfo.io/ip || curl -s ifconfig.me)

echo "[1/7] 🔧 Dipendenze"
apt update
apt install -y git curl build-essential pkg-config libssl-dev nginx

echo "[2/7] 🧬 Clono/aggiorno HighCoin"
[ -d /root/HighCoin ] || git clone https://github.com/high-cde/highcoin.git /root/HighCoin
cd /root/HighCoin
git pull || true

echo "[3/7] 🛠 Compilo HighCoin"
cargo build --release

echo "[4/7] ⚙️ Service systemd nodo HighCoin"
cat >/etc/systemd/system/highcoin.service << EOT
[Unit]
Description=HighCoin Node
After=network.target

[Service]
User=root
WorkingDirectory=/root/HighCoin
ExecStart=/root/HighCoin/target/release/node
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOT

systemctl daemon-reload
systemctl enable --now highcoin

echo "[5/7] 🌐 NGINX RPC + META"
rm -f /etc/nginx/sites-enabled/* || true

cat >/etc/nginx/sites-available/highcoin-api << EOT
server {
    listen 8181;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8765;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOT

mkdir -p /var/www/highcoin-api
cat >/var/www/highcoin-api/index.json << EOT
{
  "name": "HighCoin",
  "rpc": "http://$IP:8181",
  "network": "mainnet",
  "status": "online"
}
EOT

cat >/etc/nginx/sites-available/highcoin-meta << EOT
server {
    listen 8090;
    server_name _;

    location / {
        root /var/www/highcoin-api;
        default_type application/json;
        try_files /index.json =404;
    }
}
EOT

ln -sf /etc/nginx/sites-available/highcoin-api /etc/nginx/sites-enabled/highcoin-api
ln -sf /etc/nginx/sites-available/highcoin-meta /etc/nginx/sites-enabled/highcoin-meta

nginx -t
systemctl restart nginx

echo
echo "🎉 HighCoin node installato"
echo "🌍 RPC pubblico: http://$IP:8181"
echo "📡 META: http://$IP:8090"
