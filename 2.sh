command -v haproxy >/dev/null || apt install haproxy -y
[[ ! -f /etc/haproxy/haproxy.cfg.bak ]] && cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.bak
read -p 'plaese input wavelength ip: ' WL_IP
[[ -z "${WL_IP}" ]] && echo failed to get WL_IP ip! && exit 1

cat > /etc/haproxy/haproxy.cfg << EOF
# Global settings
global
    maxconn     204800
    user        haproxy
    group       haproxy
    daemon

defaults
    log                     global
    option                  dontlognull
    log-format %ci:%cp\ >\ %f(%fi:%fp)\ >\ %b(%bi:%bp)\ >>\ %si:%sp
    retries                 3
    timeout connect         60s
    timeout client          60s
    timeout server          60s

frontend 80
    mode tcp
    bind 0.0.0.0:80
    backlog 8192
    default_backend 80-out

frontend 443
    mode tcp
    bind 0.0.0.0:443
    backlog 8192
    default_backend 443-out

backend 80-out
    server  ser1     $WL_IP:80

backend 443-out
    server  ser2     $WL_IP:443

EOF

systemctl restart haproxy