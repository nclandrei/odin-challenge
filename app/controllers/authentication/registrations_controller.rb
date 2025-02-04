# frozen_string_literal: true

module Authentication
  class RegistrationsController < Devise::RegistrationsController
    include AuthenticationHelper
    include RackSessionFix

    private

    def respond_with(user, _opts = {})
      if user.persisted?
        sign_in(user)

        render json: authentication_response(user), status: :created
      else
        render json: {
          message: I18n.t("authentication.registrations.sign_up_failed"),
          errors: user.errors.map(&:full_message)
        }, status: :unprocessable_entity
      end
    end

    def sign_up_params
      params.require(:user).permit(:email, :password, :password_confirmation, :first_name, :last_name)
    end
  end
end
