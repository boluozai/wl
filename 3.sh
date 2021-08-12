command -v resolvconf >/dev/null || apt install resolvconf -y
resolvconf --enable-updates
sed -i 's/^nameserver/#nameserver/g' /etc/resolv.conf
echo "nameserver 127.0.0.1" >> /etc/resolv.conf
resolvconf --disable-updates
cat /etc/resolv.conf