source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.1'
gem 'rails'
gem 'mysql2'
gem 'puma'
gem 'sass-rails'
gem 'uglifier'
gem 'mini_racer', platforms: :ruby
gem 'coffee-rails'
gem 'jbuilder'
gem 'rails-i18n'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem "factory_bot_rails"
  gem 'faker'
  gem 'database_cleaner'
end

group :development do
  gem 'web-console'
  gem 'listen'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'hirb'
  gem 'hirb-unicode'
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'bullet', github: "flyerhzm/bullet"
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webdrivers'
  gem 'rspec-rails'
end

gem 'tzinfo'

# Additional
gem 'ridgepole'
gem 'slim-rails'
gem 'discordrb'
gem 'http'
gem 'daemon-spawn', :require => 'daemon_spawn'
gem 'twitter', '>= 5.17'
gem 'capistrano'
gem 'capistrano-rails'
gem 'capistrano3-puma'
gem 'capistrano-bundler'
gem 'capistrano-rbenv',   require: false
