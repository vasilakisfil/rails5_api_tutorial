class Api::V1::UserSerializer < Api::V1::BaseSerializer
  type :user
  attributes(*User.attribute_names.map(&:to_sym))

  attribute :following_state
  attribute :follower_state

  collection :users

  def following_state
    return false unless current_user

    Relationship.where(
      follower_id: current_user.id,
      followed_id: object.id
    ).exists?
  end

  def follower_state
    return false unless current_user

    Relationship.where(
      follower_id: object.id,
      followed_id: current_user.id
    ).exists?
  end

  has_one :feed, serializer: Api::V1::MicropostSerializer do
    generic :skip_data, true
    link :related, ->(obj, s) {s.api_v1_user_feed_path(user_id: obj.id)}
  end
  has_many :microposts, serializer: Api::V1::MicropostSerializer do
    generic :skip_data, true
    link :related, ->(obj, s) {s.api_v1_microposts_path(user_id: obj.id)}
  end
  has_many :followers, serializer: Api::V1::UserSerializer do
    generic :skip_data, true
    link :related, ->(obj, s) {s.api_v1_user_followers_path(user_id: obj.id)}
  end
  has_many :following, collection: {name: :followings}, serializer: Api::V1::UserSerializer do
    generic :skip_data, true
    link :related, ->(obj, s) {s.api_v1_user_followings_path(user_id: obj.id)}
  end

end
