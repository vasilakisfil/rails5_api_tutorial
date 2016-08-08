class SessionSerializer < BaseSerializer
  attributes :token, :user_id

  has_one :user

  def user
    object
  end

  def user_id
    object.id
  end
end
