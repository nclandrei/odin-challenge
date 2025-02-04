# frozen_string_literal: true

require_relative "../../app/middleware/api_response_middleware"

Rails.application.config.middleware.insert_before Warden::Manager, ApiResponseMiddleware
Rails.application.config.middleware.use Rack::Attack
