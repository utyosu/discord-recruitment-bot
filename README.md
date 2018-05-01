# Discord メンバー募集 bot

## 使い方

[イカナカマ2 botの使い方記事](https://ikanakama.ink/posts/51071)

## インストール

### Ubuntuセットアップ

```
sudo apt update
sudo apt upgrade -y
sudo apt install -y apt-file
sudo apt-file update
sudo apt install -y software-properties-common
sudo apt-add-repository ppa:brightbox/ruby-ng
sudo apt update
sudo apt install -y git bundler gem zlib1g-dev libsqlite3-dev autoconf libxml2-dev libxslt1-dev libmysqlclient-dev mysql-server ruby2.5 ruby2.5-dev
sudo gem update --system
sudo gem install bundler
wget https://download.libsodium.org/libsodium/releases/LATEST.tar.gz
tar zxvf LATEST.tar.gz
cd libsodium-stable
./configure
make && make check
sudo make install
```

### アプリケーション

```
git clone https://github.com/utyosu/discord-recruitment-bot.git
cd discord-recruitment-bot
bundle install --path vendor/bundler
sudo mysql
> create user ops;
> grant all on *.* to 'ops';
> create database discord_recruitment_bot_production character set utf8mb4;
> \d
sudo bundle exec ridgepole -c config/database.yml --apply -f db/schema -E production
```

### 起動スクリプト

1. `/etc/init.d/discord-recruitment-bot` を作成します。

```
#!/bin/sh

### BEGIN INIT INFO
# Provides:          discord-recruitment-bot
# Required-Start:    $local_fs $remote_fs $network $syslog $named
# Required-Stop:     $local_fs $remote_fs $network $syslog $named
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: starts the discord-recruitment-bot
# Description:       starts discord-recruitment-bot using start-stop-daemon
### END INIT INFO

export NAME="discord-recruitment-bot"

# 環境
#   本番: production
#   開発: development
export RAILS_ENV="production"

# `bundle exec rake secret` で発行したシークレットを入力
export SECRET_KEY_BASE="<シークレットを入力する>"

# MySQL のパスワードを入力
export DATABASE_PASSWORD=""

# botのトークン
export DISCORD_BOT_TOKEN="<botのトークンを入力>"

# botのクライアントID
export DISCORD_BOT_CLIENT_ID="<botのクライアントIDを入力>"

# discord-recruitment-bot のパス
export ROOT_DIR="/<パス>/discord-recruitment-bot"

export PID="/var/tmp/pids/${NAME}.pid"
export BUNDLE_GEMFILE="${ROOT_DIR}/Gemfile"

export RAILS_SERVE_STATIC_FILES=true

start()
{
  if [ -e $PID ]; then
    echo "$NAME already started"
    exit 1
  fi
  echo "start $NAME"
  cd $ROOT_DIR
  bundle exec rake assets:clobber
  bundle exec rails assets:precompile
  bundle exec puma -w 1 -d
  bundle exec ruby bin/discord/bot.rb start
}

stop()
{
  if [ ! -e $PID ]; then
    echo "$NAME not started"
  else
    echo "stop $NAME"
    kill -QUIT `cat ${PID}`
    rm ${PID} 2>/dev/null
  fi
  cd $ROOT_DIR
  bundle exec ruby bin/discord/bot.rb stop
}

restart()
{
    stop
    sleep 3
    start
}

case "$1" in
  start)
    restart
    ;;
  stop)
    stop
    ;;
  restart)
    restart
    ;;
  *)
    echo "Syntax Error: release [start|stop|restart]"
    ;;
esac
```

2. 実行権限を付与します。

```
sudo chmod +x /etc/init.d/discord-recruitment-bot
```

3. OS起動時に実行されるように設定します。

```
sudo update-rc.d discord-recruitment-bot defaults
```

4. 起動します。

```
sudo service discord-recruitment-bot start
```

## 開発環境

rails の起動

```
sudo bundle exec rails s
```

bot の起動

```
export DISCORD_BOT_TOKEN="<botのトークンを入力>"
export DISCORD_BOT_CLIENT_ID="<botのクライアントIDを入力>"
export DISCORD_BOT_RECRUITMENT_CHANNEL_IDS="<botが動作するチャンネルID>" #複数記載するときはカンマ区切り
sudo -E bundle exec ruby bin/discord/bot.rb nodaemon
```

## 更新

```
sudo service direct-recruitment-bot stop
git pull
sudo bundle exec ridgepole -c config/database.yml --apply -f db/schema -E production
sudo service direct-recruitment-bot start
```

## bot の動かし方が分からん！

こちらの記事が参考になりました。

[イチからDiscord Bot 。for Ruby](https://qiita.com/deneola213/items/efaeb0f5c20d44608a71)
