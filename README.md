# Discord メンバー募集 bot

## 使い方

### Ubuntuセットアップ

```
sudo -E apt-add-repository ppa:brightbox/ruby-ng
sudo apt-get update
sudo apt install -y git bundler gem zlib1g-dev libsqlite3-dev autoconf libxml2-dev libxslt1-dev libmysqlclient-dev mysql-server ruby2.5 ruby2.5-dev
sudo -E gem update --system
sudo -E gem install bundler
```

### アプリケーションのインストール

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

### 起動スクリプトの作成

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

NAME="discord-recruitment-bot"
RAILS_ENV="production"

# `bundle exec rake secret` で発行したシークレットを入力
SECRET_KEY_BASE=""

# MySQL のパスワードを入力
DATABASE_PASSWORD=""

# discord-recruitment-bot までのパスを入力
ROOT_DIR="/home/{user}/discord-recruitment-bot"

PID="${ROOT_DIR}/tmp/pids/puma.pid"
GEMFILE="${ROOT_DIR}/Gemfile"
CONFIG_PUMA="${ROOT_DIR}/config/puma.rb"
CONFIG_RACK="${ROOT_DIR}/config.ru"

start()
{
  if [ -e $PID ]; then
    echo "$NAME already started"
    exit 1
  fi
  echo "start $NAME"
  cd $ROOT_DIR
  export BUNDLE_GEMFILE=${GEMFILE}
  export SECRET_KEY_BASE='${SECRET_KEY_BASE}'
  export RAILS_SERVE_STATIC_FILES=true
  export RAILS_ENV=${RAILS_ENV}
  export DATABASE_PASSWORD=#{DATABASE_PASSWORD}
  bundle exec rake assets:clobber
  bundle exec rails assets:precompile
  bundle exec puma -w 1 -C ${CONFIG_PUMA} ${CONFIG_RACK} -d
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

3. 起動します。

```
sudo service discord-recruitment-bot start
```

4. OS起動時に実行されるように設定します。

```
sudo update-rc.d discord-recruitment-bot defaults
```
