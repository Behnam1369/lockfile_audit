# frozen_string_literal: true

require "lockfile_audit"
require "tempfile"

RSpec.configure do |config|
  # Disable the one-line "should" syntax.
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # Randomize test order to catch order dependencies.
  config.order = :random
  Kernel.srand config.seed

  config.example_status_persistence_file_path = "spec/.rspec_status"
end
