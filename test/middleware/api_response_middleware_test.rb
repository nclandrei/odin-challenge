require "test_helper"

class ApiResponseMiddlewareTest < ActionDispatch::IntegrationTest
  setup do
    @app = ->(env) { [ 500, {}, [ "Internal Server Error" ] ] }
    @middleware = ApiResponseMiddleware.new(@app)
  end

  test "should handle 401 unauthorized response" do
    assert_middleware_response(
      status_code: 401,
      app_response: [ 401, {}, [ "Unauthorized" ] ]
    )
  end

  test "should handle 404 not found response" do
    assert_middleware_response(
      status_code: 404,
      app_response: [ 404, {}, [ "Not Found" ] ]
    )
  end

  test "should handle JWT decode error" do
    assert_middleware_response(
      status_code: 401,
      app_response: ->(_env) { raise JWT::DecodeError }
    )
  end

  test "should handle ActiveRecord not found error" do
    assert_middleware_response(
      status_code: 404,
      app_response: ->(_env) { raise ActiveRecord::RecordNotFound }
    )
  end

  test "should handle exceptions with proper logging" do
    log_output = StringIO.new
    Rails.logger = Logger.new(log_output)

    # Simulate an app that raises an exception
    app_with_error = ->(env) { raise StandardError, "Test error" }
    middleware = ApiResponseMiddleware.new(app_with_error)

    # Make the request
    env = Rack::MockRequest.env_for("/some_path")
    status, headers, response = middleware.call(env)

    assert_equal 500, status
    assert_equal "application/json", headers["Content-Type"]
    assert_equal({ message: I18n.t("errors.messages.internal_server_error") }.to_json, response.first)

    log_output.rewind
    log_contents = log_output.read
    assert_includes log_contents, "Test error"
  ensure
    Rails.logger = ActiveSupport::Logger.new(STDOUT)
  end

  private

  def assert_middleware_response(status_code:, app_response:)
    middleware = ApiResponseMiddleware.new(
      app_response.is_a?(Proc) ? app_response : ->(_env) { app_response }
    )

    env = Rack::MockRequest.env_for("/some_path")
    status, headers, response = middleware.call(env)

    assert_equal status_code, status
    assert_equal "application/json", headers["Content-Type"]
    assert_equal(
      { message: I18n.t("errors.messages.#{status_code == 401 ? 'unauthenticated' : 'not_found'}") }.to_json,
      response.first
    )
  end
end
