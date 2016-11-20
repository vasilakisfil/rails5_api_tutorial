module AuthenticationHelper
  def sign_in(user)
    header('Authorization', "Token token=\"#{user.token}\"")
  end

  def create_and_sign_in_user
    user = FactoryGirl.create(:user)
    sign_in(user)
    return user
  end
  alias_method :create_and_sign_in_another_user, :create_and_sign_in_user

  def create_and_sign_in_admin
    admin = FactoryGirl.create(:admin)
    sign_in(admin)
    return admin
  end
  alias_method :create_and_sign_in_admin_user, :create_and_sign_in_admin
end

RSpec.configure do |config|
  config.include AuthenticationHelper, :type=>:api
end
