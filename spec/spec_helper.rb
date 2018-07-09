# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"
require "simplecov"
SimpleCov.start

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rspec/rails"
require "webmock/rspec"
require "rails-controller-testing"

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec
  config.infer_spec_type_from_file_location!
  config.raise_errors_for_deprecations!

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  # config.use_transactional_fixtures = true

  [:controller, :view, :request].each do |type|
    config.include Rails::Controller::Testing::TestProcess, :type => type
    config.include Rails::Controller::Testing::TemplateAssertions, :type => type
    config.include Rails::Controller::Testing::Integration, :type => type
  end
end

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"

Rails.backtrace_cleaner.remove_silencers!

# Run any available migration
# ActiveRecord::Migrator.migrate File.expand_path("../dummy/db/migrate/", __FILE__)

WebMock.disable_net_connect!(allow: 'codeclimate.com')

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# prevent Test::Unit's AutoRunner from executing during RSpec's rake task
# Relevant for Rails 3.2 tests in Ruby 1.9.3 and 2.1
Test::Unit.run = true if defined?(Test::Unit) && Test::Unit.respond_to?(:run=)
