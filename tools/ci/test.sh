#!/bin/bash

service mysql start

export RAILS_ENV=test
bundle config set without development
bundle install
bundle exec rubocop
bundle exec rails db:create
bundle exec ridgepole -c config/database.yml --apply -f db/schema -E test
bundle exec rspec
