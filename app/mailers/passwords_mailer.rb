class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    @token = user.generate_password_reset_token
    mail subject: "Reset your password", to: user.email
  end
end
