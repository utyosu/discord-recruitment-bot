# Discord メンバー募集 bot

## 使い方

```
gitclone URL
cd is
bundle install
sudo mysql
> create user ops;
> grant all on *.* to 'ops';
> create database prom_production character set utf8mb4;
> \d
sudo bundle exec ridgepole -c config/database.yml --apply -f db/schema -E production
RAILS_ENV=production bundle exec rake prom:initialize
bundle exec rails s
export DISCORD_BOT_TOKEN="botのトークン"
export DISCORD_BOT_CLIENT_ID="botのクライアントID"
bundle exec ruby bin/discord/bot.rb
```

## Ubuntuセットアップ

```
sudo -E apt-add-repository ppa:brightbox/ruby-ng
sudo apt-get update
sudo apt install -y git bundler gem zlib1g-dev libsqlite3-dev autoconf libxml2-dev libxslt1-dev libmysqlclient-dev mysql-server ruby2.5 ruby2.5-dev
sudo -E gem update --system
sudo -E gem install bundler
```
