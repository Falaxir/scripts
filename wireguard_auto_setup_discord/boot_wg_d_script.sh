#!/bin/sh

discord_webhook=""
file_config_wg="/root/client.conf"

apt install -y curl wget git
wget -O wireguard.sh https://get.vpnsetup.net/wg
bash wireguard.sh --auto
cp "$file_config_wg" "${file_config_wg%.*}.txt"

curl -H "Content-Type: multipart/form-data" -F "file=@${file_config_wg%.*}.txt" -F "payload_json={\"content\":\"Setup complete for server: \`$(hostname)\`.\nWireguard config:\"}" $discord_webhook
