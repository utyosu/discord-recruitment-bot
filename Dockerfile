FROM ubuntu:16.04

SHELL ["/bin/bash", "-c"]

ENV CONFIGURE_OPTS="--disable-install-doc --disable-install-rdoc --disable-install-capi" \
    DEBIAN_FRONTEND="noninteractive" \
    PATH="/root/.rbenv/shims:$PATH"

WORKDIR /web

ADD . .

RUN set -ex \
  && apt update \
  && apt upgrade \
  && apt install -y \
    curl \
    wget \
    mysql-server \
    rbenv \
    libssl-dev \
    libreadline-dev \
    gcc \
    g++ \
    make \
    git \
    gem \
    zlib1g-dev \
    libsqlite3-dev \
    autoconf \
    libxml2-dev \
    libxslt1-dev \
    libmysqlclient-dev \
    software-properties-common \
    bzip2 \
    tzdata \
  # Install libsodium
  && wget https://download.libsodium.org/libsodium/releases/LATEST.tar.gz -O /tmp/LATEST.tar.gz \
  && tar zxvf /tmp/LATEST.tar.gz -C /tmp \
  && cd /tmp/libsodium-stable \
  && ./configure \
  && make \
  && make install \
  # Install rbenv and ruby
  && git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build \
  && rbenv install 2.5.1 -s \
  && echo 'eval "$(rbenv init -)"' >> ~/.bashrc \
  && source ~/.bashrc \
  && rbenv rehash \
  && rbenv global 2.5.1 \
  && rbenv exec gem update --system \
  && rbenv exec gem install bundler -v '1.16.1' \
  && rbenv rehash \
  && cd /web \
  && bundle install
