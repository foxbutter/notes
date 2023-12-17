#!/bin/bash

set -x
set -e

read -p "The domain which can be resolved to this machine: " DOMAIN
read -p "The proxy username you want: " USER
read -p "The proxy password you want: " PASS

CURRENT_DIR="$(cd "$(dirname "$0")"; pwd)"

LETSENCRYPT_CERT_DIR=/etc/letsencrypt/live/${DOMAIN}
CERT=fullchain.pem
KEY=privkey.pem
GOST_CERT_DIR=${CURRENT_DIR}/cert
mkdir -p ${GOST_CERT_DIR}

BIND_IP=0.0.0.0
PORT=443

function check_env() {
    if ! cat /etc/os-release | grep -q ubuntu; then
        echo "Only support Ubuntu OS"
        exit 1
    fi

    if [ $EUID -ne 0 ]; then
        echo "This script must be run as root"
        exit 1
    fi
}

function enable_bbr() {
    kernel_version=$(uname -r)

    if [[ $(echo "$kernel_version 4.9" | awk '{if ($1 >= $2) print "1"; else print "0"}') -eq 0 ]]; then
        echo "Kernel version is less than 4.9. Skip enabling TCP BBR"
        return
    fi

    if lsmod | grep -q "tcp_bbr"; then
        echo "TCP BBR has been enabled"
        return
    fi

    echo "Enable TCP BBR"

    modprobe tcp_bbr
    echo "tcp_bbr" | tee --append /etc/modules-load.d/modules.conf
    echo "net.core.default_qdisc=fq" | tee --append /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control=bbr" | tee --append /etc/sysctl.conf

    sysctl -p
    sysctl net.ipv4.tcp_available_congestion_control
    sysctl net.ipv4.tcp_congestion_control
}

function check_dns_resolution() {
    ip=$(curl -s ifconfig.me)

    echo "Check DNS resolution, waiting for it to take effect"

    while true; do
        ns_output=$(nslookup $DOMAIN)

        if echo "$ns_output" | grep -q "$ip"; then
            echo "DNS resolution takes effect"
            return
        fi

        echo "DNS resolution is not in effect, wait 3 minutes"
        sleep 180
    done
}

function install_certbot() {
    if which certbot >/dev/null 2>&1; then
        echo "Certbot has been installed"
        return
    fi

    echo "Install Certbot"

    snap install core
    snap refresh core
    snap install --classic certbot
    ln -s /snap/bin/certbot /usr/bin/certbot
}

function register_ssl_cert() {
    install_certbot

    ufw allow 80/tcp
    certbot certonly --standalone --register-unsafely-without-email --keep-until-expiring --agree-tos -d ${DOMAIN}
}

function launch_gost() {
    if ! which docker >/dev/null 2>&1; then
        echo "Install Docker"
        apt update
        apt install docker.io -yq
    fi

    echo "Deploy and launch gost"

    docker stop gost >/dev/null 2>&1 && docker rm gost >/dev/null 2>&1

    cp -f ${LETSENCRYPT_CERT_DIR}/${CERT} ${LETSENCRYPT_CERT_DIR}/${KEY} ${GOST_CERT_DIR}

    docker run -d \
        --name gost \
        --restart unless-stopped \
        --net=host \
        -v ${GOST_CERT_DIR}:${GOST_CERT_DIR}:ro \
        ginuerzh/gost \
        -L "http2://${USER}:${PASS}@${BIND_IP}:${PORT}?cert=${GOST_CERT_DIR}/${CERT}&key=${GOST_CERT_DIR}/${KEY}&probe_resist=code:404&knock=www.google.com"

    ufw allow ${PORT}/tcp

}

function enable_warp() {
    warp_sh=/tmp/warp.sh
    curl -fsSL git.io/warp.sh -o ${warp_sh}
    chmod +x ${warp_sh}
    
    ${warp_sh} install
    ${warp_sh} proxy
}

function launch_warp_gost() {
    warp_gost_port=8443
    echo "Deploy and launch gost for WARP"

    docker run -d \
        --name gost-warp \
        --restart unless-stopped \
        --net=host \
        -v ${GOST_CERT_DIR}:${GOST_CERT_DIR}:ro \
        ginuerzh/gost \
        -L "http2://${USER}:${PASS}@${BIND_IP}:${warp_gost_port}?cert=${GOST_CERT_DIR}/${CERT}&key=${GOST_CERT_DIR}/${KEY}&probe_resist=code:404&knock=www.google.com" -F "socks5://localhost:40000"
    
    ufw allow ${warp_gost_port}/tcp
}

function generate_renew_scirpt() {
    cat << EOF > renew_cert.sh
#!/bin/bash

/usr/bin/certbot renew --force-renewal
cp -f ${LETSENCRYPT_CERT_DIR}/${CERT} ${LETSENCRYPT_CERT_DIR}/${KEY} ${GOST_CERT_DIR}
EOF
    chmod +x renew_cert.sh
}

function add_cron_jobs() {
    (crontab -l ; echo "0 0 1 * * ${CURRENT_DIR}/renew_cert.sh") | crontab -
    (crontab -l ; echo "5 0 1 * * /usr/bin/docker restart gost") | crontab -
    (crontab -l ; echo '*/10 * * * * if [ $(lsof -i :40000 | grep CLOSE_WAIT | wc -l) -gt 200 ]; then ss --tcp state CLOSE-WAIT sport = 40000 --kill; fi') | crontab -
}

check_env

enable_bbr
check_dns_resolution
register_ssl_cert
launch_gost

enable_warp
launch_warp_gost

generate_renew_scirpt
add_cron_jobs
