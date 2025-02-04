# frozen_string_literal: true

module AuthenticationHelper
  extend ActiveSupport::Concern

  private

  def authentication_response(user)
    {
      user: JSON.parse(render_to_string("users/show", formats: :json, locals: { user: })),
      access_token: extract_jwt_token,
      refresh_token: user.create_refresh_token
    }
  end

  def extract_jwt_token
    request.env["warden-jwt_auth.token"]
  end
end
