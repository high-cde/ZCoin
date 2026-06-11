#!/bin/bash
set -e

IP=$(curl -s https://ipinfo.io/ip || curl -s ifconfig.me)

echo "[1/7] 🔧 Dipendenze"
apt update
apt install -y git curl build-essential pkg-config libssl-dev nginx

echo "[2/7] 🧬 Clono/aggiorno zdos"
[ -d /root/zdos ] || git clone https://github.com/high-cde/zdos.git /root/zdos
cd /root/zdos
git pull || true

echo "[3/7] 🛠 Compilo zdos"
cargo build --release

echo "[4/7] ⚙️ Service systemd nodo zdos"
cat >/etc/systemd/system/zdos.service << EOT
[Unit]
Description=zdos Node
After=network.target

[Service]
User=root
WorkingDirectory=/root/zdos
ExecStart=/root/zdos/target/release/node
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOT

systemctl daemon-reload
systemctl enable --now zdos

echo "[5/7] 🌐 NGINX RPC + META"
rm -f /etc/nginx/sites-enabled/* || true

cat >/etc/nginx/sites-available/zdos-api << EOT
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

mkdir -p /var/www/zdos-api
cat >/var/www/zdos-api/index.json << EOT
{
  "name": "zdos",
  "rpc": "http://$IP:8181",
  "network": "mainnet",
  "status": "online"
}
EOT

cat >/etc/nginx/sites-available/zdos-meta << EOT
server {
    listen 8090;
    server_name _;

    location / {
        root /var/www/zdos-api;
        default_type application/json;
        try_files /index.json =404;
    }
}
EOT

ln -sf /etc/nginx/sites-available/zdos-api /etc/nginx/sites-enabled/zdos-api
ln -sf /etc/nginx/sites-available/zdos-meta /etc/nginx/sites-enabled/zdos-meta

nginx -t
systemctl restart nginx

echo
echo "🎉 zdos node installato"
echo "🌍 RPC pubblico: http://$IP:8181"
echo "📡 META: http://$IP:8090"
