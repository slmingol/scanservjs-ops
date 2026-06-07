FROM debian:trixie

ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    pkg-config \
    libusb-1.0-0-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libavahi-client-dev \
    gettext \
    autoconf \
    automake \
    libtool \
    python3 \
    socat \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Verify autopoint is available
RUN which autopoint || (apt-get update && apt-get install -y autopoint)

# Build SANE 1.4.0 from source using release tarball
RUN wget -q https://anduin.linuxfromscratch.org/BLFS/sane/sane-backends-1.4.0.tar.gz \
    && tar xzf sane-backends-1.4.0.tar.gz \
    && cd sane-backends-1.4.0 \
    && ./configure --prefix=/usr --sysconfdir=/etc \
    && make -j$(nproc) \
    && make install \
    && cd .. \
    && rm -rf sane-backends-1.4.0 sane-backends-1.4.0.tar.gz

# Download and install brscan4
RUN wget -q https://download.brother.com/welcome/dlf105200/brscan4-0.4.11-1.amd64.deb \
    && dpkg -i --force-all brscan4-0.4.11-1.amd64.deb \
    && rm brscan4-0.4.11-1.amd64.deb

# Configure saned
RUN echo "## allow LAN" >> /etc/sane.d/saned.conf

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 6566

ENTRYPOINT ["/entrypoint.sh"]

# Copy scan server
COPY scan-server.py /scan-server.py
