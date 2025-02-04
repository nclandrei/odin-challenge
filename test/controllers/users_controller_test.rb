require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @auth_headers = generate_auth_headers_for(@user)
  end

  test "should get user profile when authenticated" do
    get user_path, headers: @auth_headers
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal @user.email, json_response["email"]
    assert_equal @user.first_name, json_response["first_name"]
    assert_equal @user.last_name, json_response["last_name"]
  end

  test "should not get user profile when unauthenticated" do
    get user_path
    assert_response :unauthorized
  end

  test "should not get profile of another user" do
    other_user = users(:two)

    # Try to access other user's profile while authenticated as @user
    get user_path(other_user), headers: @auth_headers

    # Should still return current_user's profile
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal @user.email, json_response["email"]
    assert_not_equal other_user.email, json_response["email"]
  end

  test "should handle invalid authentication token" do
    invalid_headers = {
      "Authorization" => "Bearer invalid_token"
    }

    get user_path, headers: invalid_headers
    assert_response :unauthorized
  end

  private

  def generate_auth_headers_for(user)
    token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
    {
      "Authorization" => "Bearer #{token}"
    }
  end
end
