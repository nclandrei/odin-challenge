# frozen_string_literal: true

# Middleware that ensures consistent API responses and error handling.
# It handles both exceptions and status codes, ensuring a uniform JSON response
# format across the entire API.
class ApiResponseMiddleware
  ERROR_MESSAGES = {
    401 => "errors.messages.unauthenticated",
    404 => "errors.messages.not_found",
    500 => "errors.messages.internal_server_error"
  }.freeze

  EXCEPTION_MAP = {
    "Warden::NotAuthenticated" => 401,
    "JWT::DecodeError" => 401,
    "JWT::VerificationError" => 401,
    "Devise::JWT::InvalidAuthorizationError" => 401,
    "ActionController::RoutingError" => 404,
    "ActiveRecord::RecordNotFound" => 404
  }.freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)
    return error_response(status, I18n.t(ERROR_MESSAGES[status])) if ERROR_MESSAGES.key?(status)
    [ status, headers, response ]
  rescue StandardError => e
    handle_exception(e)
  end

  private

  def handle_exception(exception)
    status = EXCEPTION_MAP[exception.class.name] || 500

    # Log the error only if it's a 500 error so we don't pollute the logs.
    if status == 500
      Rails.logger.error(exception.message)
      Rails.logger.error(exception.backtrace.join("\n"))
    end

    error_response(status, I18n.t(ERROR_MESSAGES[status]))
  end

  def error_response(status, message)
    [ status, { "Content-Type" => "application/json" }, [ { message: }.to_json ] ]
  end
end
