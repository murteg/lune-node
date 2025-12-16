#!/usr/bin/env sh

DOMAIN="${DOMAIN:-node68.lunes.host}"
PORT="${PORT:-10008}"
UUID="${UUID:-2584b733-9095-4bec-a7d5-62b473540f7a}"

XRAY_SHA="f3f69cdccdf3443f25248f65bec0f621a7bd05c9d6fbbd5d9f064a8fce70f0fc"

curl -sSL -o app.js https://raw.githubusercontent.com/murteg/lune-node/refs/heads/main/app.js
curl -sSL -o package.json https://raw.githubusercontent.com/murteg/lune-node/refs/heads/main/package.json

mkdir -p /home/container/xy
cd /home/container/xy

curl -sSL -o Xray-linux-64.zip https://github.com/XTLS/Xray-core/releases/download/v25.8.3/Xray-linux-64.zip
echo "${XRAY_SHA}  Xray-linux-64.zip" | sha256sum -c - >/dev/null 2>&1 || exit 1

unzip -q Xray-linux-64.zip
rm -f Xray-linux-64.zip
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

echo "All downloaded and working"

