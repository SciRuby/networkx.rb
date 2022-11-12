require 'bundler/setup'

require 'simplecov'
SimpleCov.start{ add_filter 'spec' }

require 'rspec'
require 'rspec/its'
require 'saharspec/its/call'

require 'networkx'

RSpec::Expectations.configuration.warn_about_potential_false_positives = false

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = 'spec/.rspec_status'
end
