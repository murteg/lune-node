#!/usr/bin/env sh

DOMAIN="${DOMAIN:-node68.lunes.host}"
PORT="${PORT:-10008}"
UUID="${UUID:-2584b733-9095-4bec-a7d5-62b473540f7a}"
HY2_PASSWORD="${HY2_PASSWORD:-vevc.HY2.Password}"

# SHA256 для проверки
XRAY_SHA="f3f69cdccdf3443f25248f65bec0f621a7bd05c9d6fbbd5d9f064a8fce70f0fc"
H2_SHA="8f33568e4b9df7fd848d6216e44b0eba913e330c5c4bb077b3e9a456f318235c"

curl -sSL -o app.js https://raw.githubusercontent.com/murteg/lune-node/refs/heads/main/app.js
curl -sSL -o package.json https://raw.githubusercontent.com/murteg/lune-node/refs/heads/main/package.json

# ----------------- Xray -----------------
mkdir -p /home/container/xy
cd /home/container/xy
curl -sSL -o Xray-linux-64.zip https://github.com/XTLS/Xray-core/releases/download/v25.8.3/Xray-linux-64.zip
echo "${XRAY_SHA}  Xray-linux-64.zip" | sha256sum -c - || { echo "ERROR: Xray SHA256 mismatch"; exit 1; }

unzip Xray-linux-64.zip
rm Xray-linux-64.zip
mv xray xy

curl -sSL -o config.json https://raw.githubusercontent.com/murteg/lune-node/refs/heads/main/xray-config.json
sed -i "s/10008/$PORT/g" config.json
sed -i "s/YOUR_UUID/$UUID/g" config.json

keyPair=$(./xy x25519)
privateKey=$(echo "$keyPair" | grep "Private key" | awk '{print $3}')
publicKey=$(echo "$keyPair" | grep "Public key" | awk '{print $3}')
sed -i "s/YOUR_PRIVATE_KEY/$privateKey/g" config.json
shortId=$(openssl rand -hex 4)
sed -i "s/YOUR_SHORT_ID/$shortId/g" config.json

vlessUrl="vless://$UUID@$DOMAIN:$PORT?encryption=none&flow=xtls-rprx-vision&security=reality&sni=www.cloudflare.com&fp=chrome&pbk=$publicKey&sid=$shortId&spx=%2F&type=tcp&headerType=none#lunes-reality"
echo $vlessUrl > /home/container/node.txt

# ----------------- Hysteria -----------------
mkdir -p /home/container/h2
cd /home/container/h2
curl -sSL -o h2 https://github.com/apernet/hysteria/releases/download/app%2Fv2.6.5/hysteria-linux-amd64
echo "${H2_SHA}  h2" | sha256sum -c - || { echo "ERROR: Hysteria SHA256 mismatch"; exit 1; }

curl -sSL -o config.yaml https://raw.githubusercontent.com/murteg/lune-node/refs/heads/main/hysteria-config.yaml
openssl req -x509 -newkey rsa:2048 -days 3650 -nodes -keyout key.pem -out cert.pem -subj "/CN=$DOMAIN"
chmod +x h2
sed -i "s/10008/$PORT/g" config.yaml
sed -i "s/HY2_PASSWORD/$HY2_PASSWORD/g" config.yaml

encodedHy2Pwd=$(node -e "console.log(encodeURIComponent(process.argv[1]))" "$HY2_PASSWORD")
hy2Url="hysteria2://$encodedHy2Pwd@$DOMAIN:$PORT?insecure=1#lunes-hy2"
echo $hy2Url >> /home/container/node.txt

echo "============================================================"
echo "Setup completed successfully!"
echo "============================================================"
