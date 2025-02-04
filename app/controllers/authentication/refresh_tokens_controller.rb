# frozen_string_literal: true

module Authentication
  class RefreshTokensController < ApplicationController
    include AuthenticationHelper

    def create
      user = User.find_by(refresh_token: params[:refresh_token])

      if user&.refresh_token_valid?
        render json: {
          access_token: user.create_access_token,
          refresh_token: user.create_refresh_token
        }, status: :ok
      else
        head :unauthorized
      end
    end
  end
end
