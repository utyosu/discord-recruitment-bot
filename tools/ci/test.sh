#!/bin/bash

service mysql start

mysql -e 'create user "dev_ops";'
mysql -e 'grant all on *.* to "dev_ops";'

export RAILS_ENV=test
bundle config set without development
bundle install
bundle exec cap -T
bundle exec rubocop
bundle exec rails db:create
bundle exec ridgepole -c config/database.yml --apply -f db/schema -E test
bundle exec rspec
