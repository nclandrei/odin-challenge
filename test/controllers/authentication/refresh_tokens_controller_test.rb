# frozen_string_literal: true

require "test_helper"

module Authentication
  class RefreshTokensControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:one)
      @refresh_token = @user.create_refresh_token
    end

    test "should get new access token with valid refresh token" do
      post auth_refresh_token_path, params: { refresh_token: @refresh_token }
      assert_response :success

      json = JSON.parse(response.body)
      assert json["access_token"].present?
      assert json["refresh_token"].present?
      assert_not_equal @refresh_token, json["refresh_token"]
    end

    test "should fail with invalid refresh token" do
      post auth_refresh_token_path, params: { refresh_token: "invalid" }
      assert_response :unauthorized
    end

    test "should fail with expired refresh token" do
      @user.update!(refresh_token_expires_at: 1.day.ago)
      post auth_refresh_token_path, params: { refresh_token: @refresh_token }
      assert_response :unauthorized
    end

    test "should fail with missing refresh token" do
      post auth_refresh_token_path
      assert_response :unauthorized
    end
  end
end
