class Rack::Attack
  # List of sensitive endpoints that require stricter rate limiting
  SENSITIVE_ENDPOINTS = [
    "/users/sign_in",                # Login
    "/users",                        # Sign up
    "/users/password",               # Password reset
    "/users/sign_out",               # Sign out
    "/authentication/refresh_tokens" # Token refresh
  ].freeze

  # Throttle sensitive endpoints - stricter limits
  throttle("sensitive/ip", limit: Rails.application.config.rack_attack_sensitive_endpoints_request_limit, period: 1.minute) do |req|
    if SENSITIVE_ENDPOINTS.include?(req.path) && (req.post? || req.put? || req.patch?)
      req.ip
    end
  end

  # Throttle non-sensitive endpoints - more lenient limits
  throttle("api/ip", limit: Rails.application.config.rack_attack_non_sensitive_endpoints_request_limit, period: 1.minute) do |req|
    unless SENSITIVE_ENDPOINTS.include?(req.path)
      req.ip
    end
  end
end
