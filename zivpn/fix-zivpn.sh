REPO='https://raw.githubusercontent.com/dudul19/autosc/main/zivpn/'

echo "Backing up existing configuration..."
rm -rf /etc/zivpn-bakup
mv /etc/zivpn /etc/zivpn-bakup
echo -e "Uninstalling Service ZiVPN Lama"
svc="zivpn.service"
systemctl stop $svc 1>/dev/null 2>/dev/null
systemctl disable $svc 1>/dev/null 2>/dev/null
rm -f /etc/systemd/system/$svc 1>/dev/null 2>/dev/null
echo "Removed service $svc"
if pgrep "zivpn" >/dev/null; then
killall zivpn 1>/dev/null 2>/dev/null
echo "Killed running zivpn processes"
fi
echo "Cleaning Cache"
echo 3 > /proc/sys/vm/drop_caches
sysctl -w vm.drop_caches=3
echo -e "installing Service ZiVPN Baru"
export DEBIAN_FRONTEND=noninteractive
dpkg --configure -a || true
apt -f install -y || true
apt update
apt install -y sudo screen ufw ruby rubygems figlet lolcat curl wget python3-pip jq curl sudo zip figlet lolcat vnstat cron
gem install lolcat || true
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
sudo apt install iptables-persistent -y
apt install -y iptables-persistent netfilter-persistent
iptables -t nat -F PREROUTING
sudo netfilter-persistent save
echo "1. Update and install dependensi..."
apt update
apt install -y wget curl ca-certificates
update-ca-certificates
echo "2. Stop the old service..."
systemctl stop zivpn 2>/dev/null
echo "3. Remove the old binary ..."
rm -f /usr/local/bin/zivpn
echo "4. Download the official ZiVPN script..."
ARCH=$(uname -m)
case "$ARCH" in
x86_64)
FILE="zi.sh"      # amd64
;;
aarch64)
FILE="zi2.sh"       # arm64
;;
armv7l|armhf)
FILE="zi3.sh"       # arm32
;;
*)
echo "❌ Architecture not supported: $ARCH"
exit 1
;;
esac
wget -q -O /root/zi.sh "${REPO}${FILE}" 2>/dev/null
echo "5. Add executable..."
chmod +x /root/zi.sh
echo "6. Jalankan skrip instalasi ZiVPN..."
sudo /root/zi.sh
echo "Restoring the old configuration..."
rm -rf /etc/zivpn
mv /etc/zivpn-bakup /etc/zivpn
echo "7. Reload systemd and start service..."
systemctl daemon-reload
systemctl start zivpn
systemctl enable zivpn
systemctl restart zivpn
echo "8. Check service status..."
systemctl status zivpn --no-pager
echo "✅ Success Reinstall ZIVPN"
