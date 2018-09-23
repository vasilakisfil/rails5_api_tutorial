class Api::V1::SessionSerializer < Api::V1::BaseSerializer
  type :session

  attributes :email, :token, :user_id

  has_one :user, serializer: Api::V1::UserSerializer do
    link :self, ->(obj,s){"/api/v1/users/1"}
    link :related, ->(obj,s) {"/api/v1/users/1"}
  end

  def user
    object
  end

  def user_id
    object.id
  end

  def token
    object.token
  end

  def email
    object.email
  end
end
