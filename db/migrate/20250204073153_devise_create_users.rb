# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## JWT Revocation
      t.string :jti, null: false

      ## Refresh Token
      t.string :refresh_token
      t.datetime :refresh_token_expires_at

      ## User Info
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.date :registration_date, null: false, default: Date.today

      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
    add_index :users, :jti,                  unique: true
    add_index :users, :refresh_token,        unique: true
  end
end
