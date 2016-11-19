class Api::V1::SessionSerializer < Api::V1::BaseSerializer
  type :session

  attributes :email, :token, :user_id

  has_one :user, serializer: Api::V1::UserSerializer do
    link(:self) {api_v1_user_path(object.id)}
    link(:related) {api_v1_user_path(object.id)}

    object
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
