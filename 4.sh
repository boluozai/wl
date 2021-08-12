command -v dnsmasq >/dev/null || apt install dnsmasq -y
[[ ! -f /etc/dnsmasq.conf.bak ]] && cp /etc/dnsmasq.conf /etc/dnsmasq.conf.bak

cat > /etc/dnsmasq.conf << EOF
server=8.8.8.8
server=1.1.1.1
listen-address=127.0.0.1
bind-interfaces
#log-queries
#log-facility=/tmp/dnsmasq.log
EOF
systemctl restart dnsmasq

command -v sniproxy >/dev/null || apt install sniproxy -y
[[ ! -f /etc/sniproxy.conf.bak ]] && cp /etc/sniproxy.conf /etc/sniproxy.conf.bak
cat > /etc/sniproxy.conf << 'EOF'
user daemon
pidfile /var/run/sniproxy.pid

resolver {
    # Specify name server
    #
    # NOTE: it is strongly recommended to use a local caching DNS server, since
    # uDNS and thus SNIProxy only uses single socket to each name server so
    # each DNS query is only protected by the 16 bit query ID and lacks
    # additional source port randomization. Additionally no caching is
    # preformed within SNIProxy, so a local resolver can improve performance.
    nameserver 127.0.0.1

    # DNS search domain
    # search example.com

    # Specify which type of address to lookup in DNS:
    #
    # * ipv4_only   query for IPv4 addresses (default)
    # * ipv6_only   query for IPv6 addresses
    # * ipv4_first  query for both IPv4 and IPv6, use IPv4 is present
    # * ipv6_first  query for both IPv4 and IPv6, use IPv6 is present
    mode ipv4_first
}

error_log {
    syslog daemon
    priority notice
}

listener 80 {
    proto http
}

listener 443 {
    proto tls
}

table {
    .* *
}
EOF

systemctl restart sniproxy
