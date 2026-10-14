class User < ApplicationRecord
  has_secure_password reset_token: false

  normalizes :username, with: ->(value) { value.strip.downcase }
  validates :username, presence: true, uniqueness: true
  validates :active, inclusion: { in: [ true, false ] }
  validates :password, length: { minimum: 2 }, allow_nil: true
end
