FROM ubuntu:trusty as node

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update
RUN apt-get install -y build-essential libtool automake autotools-dev autoconf \
  pkg-config libssl-dev libgmp3-dev libevent-dev bsdmainutils libminiupnpc-dev git \
  software-properties-common libzmq3-dev libzmq3-dbg libzmq3

RUN apt-get install -y libboost-system-dev libboost-filesystem-dev libboost-chrono-dev \
  libboost-program-options-dev libboost-test-dev libboost-thread-dev

RUN sudo apt-get install -y git g++ cmake wget llvm-4.0 lsb-release libjsoncpp1 libjsoncpp-dev libboost1.58-all-dev libzmq5 libstdc++6 libgcc1 libpgm-5.2-0

RUN add-apt-repository ppa:bitcoin/bitcoin
RUN apt-get update
RUN apt-get install -y libdb4.8-dev libdb4.8++-dev

RUN apt-get install -y wget

# Redis - download and compile
RUN wget http://download.redis.io/redis-stable.tar.gz && \
  tar xvzf redis-stable.tar.gz && \
  cd redis-stable && \
  make
# Redis - copy binaries to directory in path
RUN cp /redis-stable/src/redis-server /usr/local/bin/
RUN cp /redis-stable/src/redis-cli /usr/local/bin/
# Redis - configure server
RUN mkdir /etc/redis && mkdir /var/redis && mkdir /var/redis/6379
RUN cp /redis-stable/utils/redis_init_script /etc/init.d/redis_6379
COPY redis.conf ./etc/redis/6379.conf
RUN update-rc.d redis_6379 defaults

# NOMP - Node Open Mining Portal
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:chris-lea/libsodium -y;
RUN echo "deb http://ppa.launchpad.net/chris-lea/libsodium/ubuntu trusty main" >> /etc/apt/sources.list;
RUN echo "deb-src http://ppa.launchpad.net/chris-lea/libsodium/ubuntu trusty main" >> /etc/apt/sources.list;
RUN apt-get update && apt-get install -y libsodium-dev;

RUN apt-get install -y \
  libboost-system-dev \
  libboost-filesystem-dev \
  libboost-chrono-dev \
  libboost-program-options-dev \
  libboost-test-dev \
  libboost-thread-dev \
  curl

RUN apt-get install -y curl

# nodejs install
RUN curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
RUN apt-get install -y nodejs

RUN git clone https://github.com/infinitEnigma/BootNOMP.git nomp && \
  cd nomp && \
  npm update

RUN mkdir /placeh

RUN wget -qO- https://github.com/xagau/Placeholders-X16R/blob/master/setup-placeh-2.0.29.2-ubuntu.tar.gz | tar xvf -C /placeh

RUN chmod +x /placeh/placehd
RUN chmod +x /placeh/placeh-cli

RUN ln -sf /placeh/placehd /usr/bin/placehd
RUN ln -sf /placeh/placeh-cli /usr/bin/placeh-cli

#wallet daemon config
COPY wallet_config_phl.conf ./root/.placehconf/placeh.conf

WORKDIR /nomp

# Pool configs
COPY znomp_config.json ./config.json
COPY coin_config_phl.json ./coins/phl.json
COPY pool_config.json ./pool_configs/phl.json

RUN npm install -g pm2

#Entrypoint
COPY entrypoint.sh ./entrypoint.sh

RUN chmod +x entrypoint.sh

EXPOSE 8080 6607 6608 3030

# CMD tail -f /dev/null

ENTRYPOINT ["./entrypoint.sh"]
