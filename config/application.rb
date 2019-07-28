require_relative 'boot'
require 'rails/all'

Bundler.require(*Rails.groups)

module IsApi
  class Application < Rails::Application
    config.load_defaults 5.2
    config.time_zone = 'Tokyo'
    config.i18n.default_locale = :ja
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.autoload_paths += Dir["#{config.root}/lib/**/"]
  end
end
