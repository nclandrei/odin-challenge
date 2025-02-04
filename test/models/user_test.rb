require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(
      email: "test@example.com",
      password: "Password1!",
      first_name: "John",
      last_name: "Doe"
    )
  end

  test "should be valid with valid attributes" do
    assert @user.valid?
  end

  test "should require first name" do
    @user.first_name = nil
    assert_not @user.valid?
    assert_includes @user.errors[:first_name], "can't be blank"
  end

  test "should require last name" do
    @user.last_name = nil
    assert_not @user.valid?
    assert_includes @user.errors[:last_name], "can't be blank"
  end

  test "should require email" do
    @user.email = nil
    assert_not @user.valid?
    assert_includes @user.errors[:email], "can't be blank"
  end

  test "should require valid email format" do
    invalid_emails = [ "test@", "@example.com", "test.com", "test@.com" ]

    invalid_emails.each do |invalid_email|
      @user.email = invalid_email
      assert_not @user.valid?, "#{invalid_email} should not be valid"
    end
  end

  test "should require unique email" do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end

  test "should require password" do
    @user.password = nil
    assert_not @user.valid?
    assert_includes @user.errors[:password], "can't be blank"
  end

  test "should enforce password complexity" do
    invalid_passwords = [
      "password", # no uppercase, number or special char
      "Password", # no number or special char
      "Password1", # no special char
      "Pass!", # no number and too short
      "Pa1!", # too short
      "password1!" # no uppercase
    ]

    invalid_passwords.each do |invalid_password|
      @user.password = invalid_password
      assert_not @user.valid?, "#{invalid_password} should not be valid"
    end
  end

  test "should set registration date on create" do
    @user.save
    assert_equal Date.today, @user.registration_date
  end

  test "should create valid refresh token" do
    @user.save
    refresh_token = @user.create_refresh_token

    assert_not_nil refresh_token
    assert_not_nil @user.refresh_token_expires_at
    assert @user.refresh_token_valid?
  end

  test "should validate refresh token expiration" do
    @user.save
    @user.refresh_token_expires_at = 1.day.ago

    assert_not @user.refresh_token_valid?
  end

  test "should create valid access token" do
    @user.save
    access_token = @user.create_access_token

    assert_not_nil access_token
    assert_kind_of String, access_token
  end
end
