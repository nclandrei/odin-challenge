# frozen_string_literal: true

module Authentication
  class SessionsController < Devise::SessionsController
    include AuthenticationHelper
    include RackSessionFix

    private

    def respond_with(user, _opts = {})
      render json: authentication_response(user), status: :ok
    end

    def respond_to_on_destroy
      if current_user
        render json: { message: I18n.t("authentication.sessions.signed_out") }, status: :ok
      else
        head :unauthorized
      end
    end
  end
end
