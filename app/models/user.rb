# frozen_string_literal: true

class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  # Password must contain at least:
  # - 1 uppercase letter
  # - 1 lowercase letter
  # - 1 number
  # - 1 special character
  # - minimum 8 characters
  PASSWORD_REQUIREMENTS = /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}\z/.freeze

  devise :database_authenticatable, :registerable,
         :validatable, :jwt_authenticatable,
         jwt_revocation_strategy: self

  validates :first_name, :last_name, presence: true

  validate :validate_password_complexity, on: :create
  validate :validate_email_format, on: :create

  before_create :set_registration_date

  def create_access_token
    Warden::JWTAuth::UserEncoder.new.call(self, :user, nil).first
  end

  def create_refresh_token
    update!(
      refresh_token: SecureRandom.urlsafe_base64,
      refresh_token_expires_at: Rails.configuration.jwt_refresh_token_expiration_in_hours.hours.from_now
    )

    refresh_token
  end

  def refresh_token_valid?
    refresh_token_expires_at && refresh_token_expires_at > Time.current
  end

  private

  def set_registration_date
    self.registration_date = Date.today
  end

  def validate_password_complexity
    return if password.blank?

    errors.add(:base, I18n.t("errors.messages.password_complexity")) unless password.match?(PASSWORD_REQUIREMENTS)
  end

  def validate_email_format
    return if email.blank?

    errors.add(:base, I18n.t("errors.messages.invalid_email_format")) unless email.match?(URI::MailTo::EMAIL_REGEXP)
  end
end
