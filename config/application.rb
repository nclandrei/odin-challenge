require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module OdinChallenge
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Rate limiting configuration.
    config.rack_attack_sensitive_endpoints_request_limit = ENV.fetch("RACK_ATTACK_SENSITIVE_ENDPOINTS_REQUEST_LIMIT", 10).to_i
    config.rack_attack_non_sensitive_endpoints_request_limit = ENV.fetch("RACK_ATTACK_NON_SENSITIVE_ENDPOINTS_REQUEST_LIMIT", 300).to_i

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # JWT configuration.
    config.jwt_access_token_expiration_in_hours = ENV.fetch("JWT_ACCESS_TOKEN_EXPIRATION_IN_HOURS", 1).to_i
    config.jwt_refresh_token_expiration_in_hours = ENV.fetch("JWT_REFRESH_TOKEN_EXPIRATION_IN_HOURS", 168).to_i

    config.api_only = true

    # Workaround for open Devise JWT issue, tracked: https://github.com/waiting-for-dev/devise-jwt/issues/235.
    config.session_store :cookie_store, key: "_interslice_session"
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use config.session_store, config.session_options

    # Ensure routing errors are caught
    config.exceptions_app = self.routes
  end
end
