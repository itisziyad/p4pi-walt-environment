
FROM waltplatform/rpi-4-b-default:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV PIP_BREAK_SYSTEM_PACKAGES=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    git cmake g++ automake libtool pkg-config make screen \
    libboost-dev libboost-program-options-dev libboost-system-dev \
    libboost-filesystem-dev libboost-thread-dev libboost-iostreams-dev \
    libgmp-dev libpcap-dev libssl-dev \
    python3 python3-pip python3-setuptools python3-pyelftools \
    protobuf-compiler libprotobuf-dev \
    libgrpc-dev libgrpc++-dev protobuf-compiler-grpc \
    dpdk dpdk-dev \
    iproute2 tcpdump net-tools iperf3 ethtool \
 && rm -rf /var/lib/apt/lists/*

RUN git clone --depth=1 --recursive https://github.com/p4lang/PI.git /opt/PI \
 && cd /opt/PI \
 && ./autogen.sh \
 && ./configure --with-proto --with-fe-cpp \
 && make -j$(nproc) \
 && make install \
 && ldconfig

RUN git clone --depth=1 https://github.com/p4lang/behavioral-model.git /opt/bmv2 \
 && cd /opt/bmv2 \
 && ./install_deps.sh \
 && pip install --break-system-packages -r requirements.txt || true \
 && ./autogen.sh \
 && ./configure --with-pi \
 && make -j$(nproc) \
 && make install \
 && ldconfig

RUN git clone --depth=1 --recursive https://github.com/p4lang/p4c.git /opt/p4c \
 && sed -i 's/\[this\](flow_join_points_t::value_type &el)/[this](const flow_join_points_t::value_type \&el)/g' \
        /opt/p4c/ir/visitor.cpp \
 && mkdir -p /opt/p4c/build \
 && cd /opt/p4c/build \
 && cmake .. -DCMAKE_BUILD_TYPE=Release \
 && make -j$(nproc) \
 && make install \
 && ldconfig

RUN git clone --depth=1 --recursive https://github.com/P4ELTE/t4p4s.git /opt/t4p4s \
 && git clone --depth=1 https://github.com/p4lang/p4pi.git /opt/p4pi

COPY enrich.sh /tmp/enrich.sh
RUN chmod +x /tmp/enrich.sh \
 && /tmp/enrich.sh \
 && rm /tmp/enrich.sh

RUN simple_switch --version || true \
 && simple_switch_grpc --version || true \
 && p4c --version || true \
 && ls /usr/local/lib/libpi* || true \
 && ls /usr/local/bin/bmv2-* /usr/local/sbin/p4pi-* || true
