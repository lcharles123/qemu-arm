FROM debian:trixie-slim

ARG VERSION_ARG="0.0"
ARG VERSION_VNC="1.5.0"

ARG DEBCONF_NOWARNINGS="yes"
ARG DEBIAN_FRONTEND="noninteractive"
ARG DEBCONF_NONINTERACTIVE_SEEN="true"

RUN set -eu && \
    apt-get update && \
    apt-get --no-install-recommends -y install \
        tini \
        wget \
        7zip \
        nginx \
        procps \
        seabios \
        iptables \
        iproute2 \
        apt-utils \
        dnsmasq \
        xz-utils \
        net-tools \
        qemu-utils \
        genisoimage \
        ca-certificates \
        netcat-openbsd \
        qemu-system-arm \
        qemu-efi-aarch64 && \
    apt-get clean && \
    mkdir -p /usr/share/novnc && \
    wget "https://github.com/novnc/noVNC/archive/refs/tags/v${VERSION_VNC}.tar.gz" -O /tmp/novnc.tar.gz -q --timeout=10 && \
    tar -xf /tmp/novnc.tar.gz -C /tmp/ && \
    cd "/tmp/noVNC-${VERSION_VNC}" && \
    mv app core vendor package.json *.html /usr/share/novnc && \
    sed -i "s|UI\.initSetting('path', 'websockify')|UI.initSetting('path', window.location.pathname.replace(/[^/]*$/, '').substring(1) + 'websockify')|" /usr/share/novnc/app/ui.js && \
    unlink /etc/nginx/sites-enabled/default && \
    sed -i 's/^worker_processes.*/worker_processes 1;/' /etc/nginx/nginx.conf && \
    echo "$VERSION_ARG" > /run/version && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --chmod=755 ./src /run/

ADD --chmod=664 https://raw.githubusercontent.com/qemus/qemu-docker/master/web/index.html /var/www/index.html
ADD --chmod=664 https://raw.githubusercontent.com/qemus/qemu-docker/master/web/js/script.js /var/www/js/script.js
ADD --chmod=664 https://raw.githubusercontent.com/qemus/qemu-docker/master/web/css/style.css /var/www/css/style.css
ADD --chmod=664 https://raw.githubusercontent.com/qemus/qemu-docker/master/web/img/favicon.svg /var/www/img/favicon.svg
ADD --chmod=744 https://raw.githubusercontent.com/qemus/qemu-docker/master/web/nginx.conf /etc/nginx/sites-enabled/web.conf

VOLUME /storage
EXPOSE 22 5900 8006

ENV CPU_CORES="1"
ENV RAM_SIZE="1G"
ENV DISK_SIZE="16G"
ENV BOOT="http://example.com/image.iso"
# set BIOS to the mounted bios file inside container, i.e. /u-boot.bin
# in this case, BOOT must be the OS image mounted inside container, i.e. /system.img.qcow2
ENV BIOS=""

ENTRYPOINT ["/usr/bin/tini", "-s", "/run/entry.sh"]
