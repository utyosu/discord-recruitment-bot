#!/bin/bash

# Rubyにパスを通す
export PATH="/root/.rbenv/bin:/root/.rbenv/shims:$PATH"

# Dockerfileがマルチレイヤのとき、MySQLを起動する前に以下コマンドの実行が必要
find /var/lib/mysql -type f -exec touch {} \;

REPOSITORY=${1}
BRANCH=${2}
SCRIPT_PATH=${3}

mkdir repository
git clone -b ${BRANCH} ${REPOSITORY} repository
cd repository

. ${SCRIPT_PATH}
