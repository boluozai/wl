command -v curl >/dev/null || apt install curl -y

command -v dnsmasq >/dev/null || apt install dnsmasq -y
[[ ! -f /etc/dnsmasq.conf.bak ]] && cp /etc/dnsmasq.conf /etc/dnsmasq.conf.bak

PROXY_DOMAINS_LIST_URL="https://github.com/ab77/netflix-proxy/raw/master/proxy-domains.txt"

curl -fsSL "$PROXY_DOMAINS_LIST_URL" > proxy-domains.txt

EXTIP=$(curl -s ip.sb)

[[ -z "${EXTIP}" ]] && echo failed to get external ip! && exit 1

cat >> proxy-domains.txt << EOF
abema.jp
abema.io
abema.tv
abematv.bucketeer.jp
indazn.com
hulu.jp
disney.co.jp
unext.jp
paravi.jp
cygames.jp
nicovideo.jp
stream.ne.jp
videomarket.jp
viu.com
viu.now.com
disneyplus.com
bamgrid.com
biguz.net
EOF

cat > /etc/dnsmasq.conf << EOF
server=8.8.8.8
server=1.1.1.1
listen-address=0.0.0.0
bind-interfaces
#log-queries
#log-facility=/tmp/dnsmasq.log

EOF

for domain in $(cat proxy-domains.txt); do
    printf "address=/${domain}/${EXTIP}\n" | tee -a /etc/dnsmasq.conf
done
systemctl restart dnsmasq