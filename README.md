# Discord メンバー募集 bot

## 使い方

[イカナカマ2 botの使い方記事](https://ikanakama.ink/posts/51071)

## インストール

### セットアップ

OS: Ubuntu 16.04 LTS

```
ansible-playbook -i tools/ansible/inventories/production tools/ansible/rails_server.yml --diff --ask-vault-pass
```

### デプロイ

```
bundle exec cap production deploy
```

## メンテナンス

- Railsサーバの停止

```
bundle exec cap production puma:stop
```

- Railsサーバの起動

```
bundle exec cap production puma:start
```

- Railsサーバの再起動

```
bundle exec cap production puma:restart
```

- Botの停止

```
bundle exec cap production bot:stop
```

- Botの起動

```
bundle exec cap production bot:start
```

- Botの再起動

```
bundle exec cap production bot:restart
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
export DISCORD_BOT_RECRUITMENT_CHANNEL_ID="<botが動作するチャンネルID>"
bundle exec ruby bin/discord/bot.rb nodaemon
```

## bot の動かし方が分からん！

こちらの記事が参考になりました。

[イチからDiscord Bot 。for Ruby](https://qiita.com/deneola213/items/efaeb0f5c20d44608a71)
