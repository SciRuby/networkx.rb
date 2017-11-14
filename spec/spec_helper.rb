require 'simplecov'
SimpleCov.start do
  add_filter 'spec'
  # minimum_coverage_by_file 95
end

require 'bundler/setup'

require 'rspec'
require 'rspec/its'
require 'saharspec/its/call'

require 'networkx'

require_relative 'support/shared_contexts'
require_relative 'support/shared_examples'
require_relative 'support/custom_matchers'

RSpec::Expectations.configuration.warn_about_potential_false_positives = false

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

class String
  # allows to pretty test agains multiline strings:
  #   %Q{
  #     |test
  #     |me
  #   }.unindent # =>
  # "test
  # me"
  def unindent
    gsub(/\n\s+?\|/, "\n") # for all lines looking like "<spaces>|" -- remove this.
      .gsub(/\|\n/, "\n")  # allow to write trailing space not removed by editor
      .gsub(/^\n|\n\s+$/, '') # remove empty strings before and after
  end
end
