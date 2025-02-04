Rails.application.config.filter_parameters += [
  :passw, :email, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn, :cvv, :cvc, :password, :refresh_token, :jwt, :access_token, :jti, :encrypted_password
]
