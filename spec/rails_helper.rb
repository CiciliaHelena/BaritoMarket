require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'
require 'webmock/rspec'
require 'database_cleaner'
require 'fakeredis/rspec'
require 'coveralls'
require 'webdrivers'
require 'selenium/webdriver'
require 'simplecov'
require 'simplecov-console'
require 'sidekiq/testing'
require 'pry'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

# Patch for issue with Chrome 75
# Ref: https://github.com/titusfortner/webdrivers/issues/126#issuecomment-499972539
Webdrivers.cache_time = 1
Webdrivers::Chromedriver.required_version = '74.0.3729.6'

# Configure Capybara Driver
Capybara.server = :puma, { Silent: true }
Capybara.register_driver :custom_headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w(headless disable-gpu no-sandbox) }
  )

  Capybara::Selenium::Driver.new app,
    browser: :chrome,
    desired_capabilities: capabilities
end
Capybara.javascript_driver = :custom_headless_chrome

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.include Warden::Test::Helpers
  config.include GateClientHelper
  config.include AppViewHelper

  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.before(:suite) do
    ENV['ENABLE_CAS_INTEGRATION'] = 'true'

    WebMock.disable_net_connect!(allow: ['localhost', '127.0.0.1', /selenium/, 'chromedriver.storage.googleapis.com'])
    Sidekiq::Testing.fake!
    DatabaseCleaner.clean_with(:truncation)

    require "#{File.dirname(__FILE__)}/seeds.rb"
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  Coveralls.wear!
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([SimpleCov::Formatter::Console])
  SimpleCov.start
end
