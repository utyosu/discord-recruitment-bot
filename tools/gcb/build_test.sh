#!/bin/bash
git fetch
git checkout ${1}
service mysql start
mysql -e 'create user dev_ops; grant all on *.* to dev_ops; create database discord_recruitment_bot_test character set utf8mb4;'
bundle install
bundle exec ridgepole -c config/database.yml --apply -f db/schema -E test
bundle exec rspec
