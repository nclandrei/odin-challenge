require "test_helper"

class IntegrationTest < ActionDispatch::IntegrationTest
  test "full user authentication flow" do
    # Try signup with invalid parameters
    post "/users", params: {
      user: {
        email: "invalid-email",
        password: "weak",
        first_name: "",
        last_name: ""
      }
    }
    assert_response :unprocessable_entity

    # Signup with valid parameters
    post "/users", params: {
      user: {
        email: "test@example.com",
        password: "Password1!",
        first_name: "John",
        last_name: "Doe"
      }
    }
    assert_response :success
    access_token = response.headers["Authorization"].split(" ").last
    refresh_token = JSON.parse(response.body)["refresh_token"]

    # Get user details with valid token
    get "/user", headers: { "Authorization": "Bearer #{access_token}" }
    assert_response :success
    user_data = JSON.parse(response.body)
    assert_equal "test@example.com", user_data["email"]
    assert_equal "John", user_data["first_name"]

    # Refresh token
    post "/auth/refresh_token", params: { refresh_token: refresh_token }
    assert_response :success
    new_access_token = JSON.parse(response.body)["access_token"]

    # Get user with new access token
    get "/user", headers: { "Authorization": "Bearer #{new_access_token}" }
    assert_response :success

    # Try with invalid token
    get "/user", headers: { "Authorization": "Bearer invalid_token" }
    assert_response :unauthorized

    # Logout
    delete "/users/sign_out", headers: { "Authorization": "Bearer #{new_access_token}" }
    assert_response :success

    # Try login with incorrect credentials
    post "/users/sign_in", params: {
      user: {
        email: "test@example.com",
        password: "wrong_password"
      }
    }
    assert_response :unauthorized

    # Login with correct credentials
    post "/users/sign_in", params: {
      user: {
        email: "test@example.com",
        password: "Password1!"
      }
    }
    assert_response :success
    final_access_token = response.headers["Authorization"].split(" ").last

    # Verify user data after login
    get "/user", headers: { "Authorization": "Bearer #{final_access_token}" }
    assert_response :success
    final_user_data = JSON.parse(response.body)
    assert_equal "test@example.com", final_user_data["email"]
    assert_equal "John", final_user_data["first_name"]
    assert_equal "Doe", final_user_data["last_name"]
  end
end
