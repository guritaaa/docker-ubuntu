FROM --platform=linux/amd64 kalilinux/kali-rolling

ARG ROOT_PASSWORD=root
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Jakarta \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# 1. Update, install dependencies, dan locale/timezone sekaligus dalam 1 layer
RUN apt-get update && apt-get install --no-install-recommends -y \
    # Core & Init
    dbus systemd-sysv \
    # Networking
    net-tools iproute2 iputils-ping dnsutils traceroute netcat-openbsd \
    curl wget rsync telnet socat \
    # SSH Server & Client
    openssh-server openssh-client \
    # Editor & Shell utilities
    vim nano less man-db bash-completion \
    # Monitoring & Process
    htop lsof psmisc procps \
    # Archiving
    tar gzip bzip2 xz-utils zip unzip \
    # Security & Daemons
    sudo ufw fail2ban \
    # Time & Locale
    tzdata locales \
    # Logging & Cron
    cron logrotate rsyslog \
    # SSL & Certificates
    openssl ca-certificates \
    # Utilities
    jq tree file bc debianutils \
    # Package management helpers
    apt-utils apt-transport-https gnupg lsb-release \
    # Setup timezone & locale
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen \
    && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    # Setup SSH base config & password
    && mkdir -p /var/run/sshd \
    && echo "root:${ROOT_PASSWORD}" | chpasswd \
    && sed -i 's/#*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && sed -i 's/#*PrintLastLog.*/PrintLastLog no/' /etc/ssh/sshd_config \
    && sed -i 's/^session.*pam_motd.so/#&/' /etc/pam.d/sshd \
    # Matikan MOTD bawaan
    && rm -rf /etc/update-motd.d/* /etc/motd /etc/issue /etc/issue.net \
    && touch /etc/motd /etc/issue /etc/issue.net \
    # Cleanup dalam layer yang sama
    && apt-get autoremove --purge -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/log/*

# 2. Setup Login Banner & SSH Pre-Auth Banner
RUN printf '\n  GURITA VPS (Kali) - Authorized Access Only\n\n' > /etc/ssh/banner \
    && echo 'Banner /etc/ssh/banner' >> /etc/ssh/sshd_config \
    && cat <<'EOF' > /etc/profile.d/gurita-banner.sh
#!/bin/bash

case $- in
    *i*) ;;
    *) return ;;
esac

clear
echo ""
echo "=========================================="
echo "       G U R I T A   V P S  (KALI)"
echo "=========================================="
echo ""
echo "    ____  _   _ ____ ___ _____  _"
echo "   / ___|| | | |  _ \\_ _|_   _|/ \\"
echo "  | |  _ | | | | |_) | |   | | / _ \\"
echo "  | |_| || |_| |  _ <| |   | |/ ___ \\"
echo "   \\____| \\___/|_| \\_\\_|   |_/_/   \\_\\"
echo ""
echo "=========================================="
echo " User   : $(whoami)"
echo " Uptime : $(uptime -p 2>/dev/null || echo 'N/A')"
echo " Date   : $(date)"
echo "=========================================="
echo ""
EOF
RUN chmod +x /etc/profile.d/gurita-banner.sh

# 3. Setup host key generator saat container dinyalakan pertama kali
RUN cat <<'EOF' > /entrypoint.sh
#!/bin/bash
set -e

# Generate SSH host keys jika belum ada
ssh-keygen -A

exec "$@"
EOF
RUN chmod +x /entrypoint.sh

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D", "-e"]
