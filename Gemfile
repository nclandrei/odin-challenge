source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.1"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 6.4.2"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder", "~> 2.13.0"

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache", "~> 0.4.1"
gem "solid_queue", "~> 0.3.0"
gem "solid_cable", "~> 0.3.0"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", "~> 1.18.3", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", "~> 1.3.1", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", "~> 0.1.1", require: false

# Add Devise and Devise JWT for authentication [https://github.com/heartcombo/devise]
gem "devise", "~> 4.9.0"
gem "devise-jwt", "~> 0.10.0"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
gem "rack-cors", "~> 2.0.2"

# Add rate limiting support [https://github.com/rack/rack-attack]
gem "rack-attack", "~> 6.7.0"

# Load environment variables from .env file.
gem "dotenv-rails", "~> 2.8.1"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", "~> 1.9.1", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", "7.0.0", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", "~> 1.0.0", require: false
end

group :test do
  gem "simplecov", "~> 0.21.2", require: false
  gem "mocha", "~> 2.7.1", require: false
end
