user ||= @user

json.extract! user, :email, :first_name, :last_name, :registration_date
