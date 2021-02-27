source "https://rubygems.org"

ruby "2.6.6"

# Basic
gem "coffee-rails"
gem "jbuilder"
gem "mini_racer", platforms: :ruby
gem "mysql2"
gem "puma"
gem "rails"
gem "rails-i18n"
gem "sass-rails"
gem "tzinfo"
gem "uglifier"

group :development, :test do
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "database_cleaner"
  gem "factory_bot_rails"
  gem "faker"
  gem "i18n-tasks"
  gem "rubocop", "~> 0.83.0", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem "bullet", github: "flyerhzm/bullet"
  gem "listen"
  gem "pry-byebug"
  gem "pry-rails"
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "coveralls", require: false
  gem "rspec-rails"
  gem "selenium-webdriver"

  # simplecov
  #   simplecov 0.18.2(厳密にはsimplecov-html 0.12.0)で
  #   出力コードが表示できない不具合があるので一旦0.18.2に固定する
  #   issueは上がっている模様
  #   https://github.com/colszowka/simplecov-html/issues/92
  #
  #   coverallsがsimplecov 0.16系までしか対応していないので
  #   0.16.1に固定する。対応したらバージョンアップする。
  gem "simplecov", "~> 0.16.0", require: false
  gem "webdrivers"
end

# Dployment
gem "capistrano", require: false
gem "capistrano-bundler", require: false
gem "capistrano-rails", require: false
gem "capistrano-rbenv", require: false
gem "capistrano3-puma", ">= 4", require: false

# Settings
gem "config"
gem "ridgepole", require: false
gem "yaml_vault", require: false

# Application
gem "daemon-spawn", require: "daemon_spawn"
gem "discordrb"
gem "slack-ruby-client"
gem "slim-rails"
gem "timers"
gem "twitter", ">= 6.2.0"
