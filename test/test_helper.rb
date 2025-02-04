ENV["RAILS_ENV"] ||= "test"

# SimpleCov must be started before any application code is loaded
require "simplecov"
SimpleCov.start "rails" do
  add_filter "/test/"  # Exclude test files
  add_filter "/config/"  # Exclude config files
  add_filter "/db/"  # Exclude database files
  add_filter "/vendor/"  # Exclude vendor files
  add_filter "/app/controllers/concerns/rack_session_fix.rb" # Exclude rack session fix as it's a monkey patch

  # Ensure coverage is generated even in parallel tests
  track_files "app/**/*.rb"
end

require_relative "../config/environment"
require "rails/test_help"
require "mocha/minitest"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all
  end
end
