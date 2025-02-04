# frozen_string_literal: true

require "test_helper"

module Authentication
  class RegistrationsControllerTest < ActionDispatch::IntegrationTest
    VALID_PASSWORD = "Password1!".freeze
    VALID_USER_PARAMS = {
      email: "new@example.com",
      first_name: "John",
      last_name: "Doe"
    }.freeze

    test "should register user with valid data" do
      assert_difference("User.count") do
        post user_registration_path, params: {
          user: VALID_USER_PARAMS.merge(
            password: VALID_PASSWORD,
            password_confirmation: VALID_PASSWORD
          )
        }
      end

      assert_response :created
      json = JSON.parse(response.body)
      assert json["access_token"].present?
      assert json["refresh_token"].present?
      assert json["user"].present?
      assert_equal VALID_USER_PARAMS[:email], json["user"]["email"]
      assert_equal VALID_USER_PARAMS[:first_name], json["user"]["first_name"]
      assert_equal VALID_USER_PARAMS[:last_name], json["user"]["last_name"]
    end

    test "should fail with invalid email format" do
      invalid_emails = [ "invalid-email", "test@", "@example.com", "test@.com", "test@com." ]

      invalid_emails.each do |invalid_email|
        assert_no_difference("User.count") do
          post user_registration_path, params: {
            user: VALID_USER_PARAMS.merge(
              email: invalid_email,
              password: VALID_PASSWORD,
              password_confirmation: VALID_PASSWORD
            )
          }
        end
        assert_response :unprocessable_entity
        json = JSON.parse(response.body)
        assert_includes json["errors"], I18n.t("errors.messages.invalid_email_format")
      end
    end

    test "should fail with mismatched passwords" do
      assert_no_difference("User.count") do
        post user_registration_path, params: {
          user: VALID_USER_PARAMS.merge(
            password: VALID_PASSWORD,
            password_confirmation: "different"
          )
        }
      end
      assert_response :unprocessable_entity
      json = JSON.parse(response.body)
      assert_includes json["errors"], "Password confirmation doesn't match Password"
    end

    test "should fail with duplicate email" do
      existing_user = users(:one)

      assert_no_difference("User.count") do
        post user_registration_path, params: {
          user: VALID_USER_PARAMS.merge(
            email: existing_user.email,
            password: VALID_PASSWORD,
            password_confirmation: VALID_PASSWORD
          )
        }
      end
      assert_response :unprocessable_entity
      json = JSON.parse(response.body)
      assert_includes json["errors"], "Email has already been taken"
    end

    test "should fail with missing required fields" do
      assert_no_difference("User.count") do
        post user_registration_path, params: {
          user: {
            email: "new@example.com",
            password: VALID_PASSWORD,
            password_confirmation: VALID_PASSWORD
          }
        }
      end
      assert_response :unprocessable_entity

      json = JSON.parse(response.body)
      assert_includes json["errors"], "First name can't be blank"
      assert_includes json["errors"], "Last name can't be blank"
    end

    # Password complexity tests
    test "should fail with empty password" do
      assert_password_error("", "Password can't be blank")
    end

    test "should fail with password too short" do
      assert_password_error("Ab1!xyz", "Password is too short (minimum is 8 characters)")
    end

    test "should fail with password missing uppercase letter" do
      assert_password_error("password1!")
    end

    test "should fail with password missing lowercase letter" do
      assert_password_error("PASSWORD1!")
    end

    test "should fail with password missing number" do
      assert_password_error("Password!@")
    end

    test "should fail with password missing special character" do
      assert_password_error("Password123")
    end

    test "should fail with password containing spaces" do
      assert_password_error("Password 1!")
    end

    private

    def assert_password_error(password, expected_error = nil)
      assert_no_difference("User.count") do
        post user_registration_path, params: {
          user: VALID_USER_PARAMS.merge(
            password: password,
            password_confirmation: password
          )
        }
      end
    end
  end
end
