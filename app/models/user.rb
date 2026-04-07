# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  validates :name, presence: true
  validates :email, format: { with: /\A([^\s]+)((?:[-a-z0-9]\.)[a-z]{2,})\z/i }, uniqueness: { case_sensitive: false }

  has_many :sessions, dependent: :destroy
  has_many :refresh_tokens, dependent: :delete_all
  has_many :blacklisted_tokens, dependent: :delete_all
  has_many :password_reset_tokens, dependent: :delete_all

  normalizes :email, with: ->(e) { e.strip.downcase }

  # For Google OAuth - create random password for OAuth users
  def self.from_omniauth(auth)
    data = auth.info
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = data.email
      user.password = SecureRandom.hex(20)
      user.name = data.name
      user.avatar_url = data.image
    end
  end

  # For password reset tokens
  def generate_password_reset_token
    signed_id expires_in: 20.minutes, purpose: :password_reset
  end

  def self.find_by_password_reset_token!(token)
    find_signed!(token, purpose: :password_reset)
  end
end
