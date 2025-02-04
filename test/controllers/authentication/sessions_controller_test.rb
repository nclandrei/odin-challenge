# frozen_string_literal: true

require "test_helper"

module Authentication
  class SessionsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:one)
    end

    test "should sign in user with valid credentials" do
      post user_session_path, params: { user: { email: @user.email, password: "password123" } }
      assert_response :success

      json = JSON.parse(response.body)
      assert json["access_token"].present?
      assert json["refresh_token"].present?
      assert json["user"].present?
      assert_equal @user.email, json["user"]["email"]
    end

    test "should fail with invalid password" do
      post user_session_path, params: { user: { email: @user.email, password: "wrong" } }
      assert_response :unauthorized
    end

    test "should fail with invalid email" do
      post user_session_path, params: { user: { email: "wrong@example.com", password: "password123" } }
      assert_response :unauthorized
    end

    test "should fail with missing credentials" do
      post user_session_path
      assert_response :unauthorized
    end

    test "should sign out user with valid token" do
      # First sign in to get the token
      post user_session_path, params: { user: { email: @user.email, password: "password123" } }
      token = JSON.parse(response.body)["access_token"]

      # Then sign out
      delete destroy_user_session_path, headers: { 'Authorization': "Bearer #{token}" }
      assert_response :success
    end

    test "should fail sign out with invalid token" do
      delete destroy_user_session_path, headers: { 'Authorization': "Bearer invalid" }
      assert_response :unauthorized
    end

    test "should fail sign out without token" do
      delete destroy_user_session_path
      assert_response :unauthorized
    end
  end
end
