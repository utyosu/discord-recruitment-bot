#!/bin/bash
git fetch
git checkout ${1}
service mysql start
bundle install
bundle exec ridgepole -c config/database.yml --apply -f db/schema -E test
bundle exec rspec
