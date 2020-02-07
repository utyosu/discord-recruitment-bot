if ENV['CI']
  require 'coveralls'
  Coveralls.wear!('rails')
else
  require 'simplecov'
  SimpleCov.start 'rails'
end

ENV["RAILS_ENV"] ||= 'test'

require File.expand_path('../config/environment', __dir__)
require 'rspec/rails'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.include Rails.application.routes.url_helpers
  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
