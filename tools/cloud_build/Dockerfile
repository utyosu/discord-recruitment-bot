# ビルド方法 (プロジェクトルートで実行)
# $ docker build -t build-rails . -f tools/cloud_build/Dockerfile

FROM ubuntu:16.04

SHELL ["/bin/bash", "-c"]

ENV DEBIAN_FRONTEND="noninteractive"
ENV RUBY_VERSION="2.5.1"
ENV BUNDLER_VERSION="2.1.4"

WORKDIR /app

ADD Gemfile .
ADD Gemfile.lock .

RUN set -x \
  && apt update \
  && apt install -y \
    curl \
    libssl-dev \
    libreadline-dev \
    zlib1g-dev \
    build-essential \
    git \
    mysql-client \
    libmysqlclient-dev \
    tzdata \
    mysql-server \
  # Install rbenv and ruby
  && git clone https://github.com/sstephenson/rbenv.git ~/.rbenv \
  && git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build \
  && CONFIGURE_OPTS='--disable-install-rdoc' /root/.rbenv/bin/rbenv install ${RUBY_VERSION} -s \
  && /root/.rbenv/bin/rbenv global ${RUBY_VERSION} \
  # Install bundler
  && echo 'gem: --no-rdoc --no-ri' > /root/.gemrc \
  && /root/.rbenv/shims/gem install bundler -v ${BUNDLER_VERSION} \
  # bundle install
  && /root/.rbenv/shims/bundle config set without development \
  && /root/.rbenv/shims/bundle install \
  && rm Gemfile Gemfile.lock

COPY /tools/cloud_build/run.sh .
