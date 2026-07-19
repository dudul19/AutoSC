#!/bin/bash

REPO='https://raw.githubusercontent.com/dudul19/autosc/main/zivpn/'
set -euo pipefail

CACHE_DIR="/etc/zivpn"
IP_FILE="$CACHE_DIR/ip.txt"
ISP_FILE="$CACHE_DIR/isp.txt"

mkdir -p "$CACHE_DIR"

json="$(curl -4 -fsS --max-time 10 'https://ipwho.is/' 2>/dev/null || true)"
IP="$(printf '%s' "$json" | sed -nE 's/.*"ip"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p' | head -n1)"
ISP="$(printf '%s' "$json" | sed -nE 's/.*"isp"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p' | head -n1)"

: "${IP:=N/A}"
: "${ISP:=N/A}"

tmp_ip="$(mktemp)"
tmp_isp="$(mktemp)"

printf '%s\n' "$IP"  > "$tmp_ip"
printf '%s\n' "$ISP" > "$tmp_isp"

mv "$tmp_ip"  "$IP_FILE"
mv "$tmp_isp" "$ISP_FILE"
chmod 644 "$IP_FILE" "$ISP_FILE"

echo "┌────────────────────────────────────┐"
echo "| IP  : $IP"
echo "| ISP : $ISP"
echo "| Saved:"
echo "|  - $IP_FILE"
echo "|  - $ISP_FILE"
echo "└────────────────────────────────────┘"
echo

wget -q "${REPO}zivpn-manager" -O /usr/local/bin/zivpn-manager 2>/dev/null

if [ -f "/usr/local/bin/zivpn-manager" ]; then
    chmod +x /usr/local/bin/zivpn-manager 
    /usr/local/bin/zivpn-manager
else
    echo "[ ERROR ] Gagal mengunduh zivpn-manager. Periksa koneksi atau URL repo."
    exit 1
fi
