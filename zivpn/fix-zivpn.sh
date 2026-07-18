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
echo "1. Update OS dan install dependensi..."
apt update
apt install -y wget curl ca-certificates
update-ca-certificates
echo "2. Hentikan service lama (jika ada)..."
systemctl stop zivpn 2>/dev/null
echo "3. Hapus binary lama (jika ada)..."
rm -f /usr/local/bin/zivpn
echo "4. Download skrip resmi ZiVPN..."
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
echo "❌ Arsitektur tidak didukung: $ARCH"
exit 1
;;
esac
echo "Terdeteksi arsitektur: $ARCH → pakai $FILE"
wget -O /root/zi.sh "${REPO}${FILE}"
echo "5. Beri izin executable..."
chmod +x /root/zi.sh
echo "6. Jalankan skrip instalasi ZiVPN..."
sudo /root/zi.sh
echo "Mengembalikan konfigurasi lama..."
rm -rf /etc/zivpn
mv /etc/zivpn-bakup /etc/zivpn
echo "7. Reload systemd dan start service..."
systemctl daemon-reload
systemctl start zivpn
systemctl enable zivpn
systemctl restart zivpn
echo "8. Cek status service..."
systemctl status zivpn --no-pager
echo "✅ Instalasi selesai. Service ZiVPN harusnya aktif dan panel bisa mendeteksi."
