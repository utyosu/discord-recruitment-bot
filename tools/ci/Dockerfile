# ビルド方法 (プロジェクトルートで実行)
# $ docker build -t utyosu/build-rails:latest . -f tools/ci/Dockerfile

FROM ubuntu:16.04

SHELL ["/bin/bash", "-c"]

ENV RUBY_VERSION="2.6.6"
ENV BUNDLER_VERSION="2.1.4"
ENV DEBIAN_FRONTEND="noninteractive"
ENV PATH=/root/.rbenv/bin:/root/.rbenv/shims:$PATH

WORKDIR /app

COPY Gemfile .
COPY Gemfile.lock .

RUN set -x \
  && apt update \
  && apt install -y \
    build-essential \
    curl \
    git \
    libssl-dev \
    libreadline-dev \
    libmysqlclient-dev \
    mysql-client \
    mysql-server \
    tzdata \
    zlib1g-dev \
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
  # delete unused file
  && rm -rf /var/lib/apt/lists/* \
  && rm Gemfile Gemfile.lock
