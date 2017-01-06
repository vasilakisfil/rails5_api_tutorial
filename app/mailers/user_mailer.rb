class UserMailer < ApplicationMailer
  helper_method :ember_activation_url

  def account_activation(user)
    @user = user
    mail to: user.email, subject: "Account activation"
  end

  def ember_account_activation(user)
    @user = user
    mail to: user.email, subject: "Account activation"
  end

  def password_reset(user)
    @user = user
    mail to: user.email, subject: "Password reset"
  end

  def ember_activation_url(token, email)
    "#{Rails.application.secrets.ember_activation_url}?token=#{token}&email=#{email}".html_safe
  end
end
