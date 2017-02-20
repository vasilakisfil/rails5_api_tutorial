class Api::V1::UserSerializer < Api::V1::BaseSerializer
  attributes(*User.attribute_names.map(&:to_sym))

  attribute :following_state
  attribute :follower_state

  def following_state
    Relationship.where(
      follower_id: current_user.id,
      followed_id: object.id
    ).exists?
  end

  def follower_state
    Relationship.where(
      follower_id: object.id,
      followed_id: current_user.id
    ).exists?
  end

  has_one :feed, serializer: Api::V1::MicropostSerializer do
    include_data(false)
    link(:related) {api_v1_user_feed_path(user_id: object.id)}
  end

  has_many :microposts, serializer: Api::V1::MicropostSerializer do
    include_data(false)
    link(:related) {api_v1_microposts_path(user_id: object.id)}
  end

  has_many :followers, serializer: Api::V1::UserSerializer do
    include_data(false)
    link(:related) {api_v1_user_followers_path(user_id: object.id)}
  end

  has_many :followings, key: :followings, serializer: Api::V1::UserSerializer do
    include_data(false)
    link(:related) {api_v1_user_followings_path(user_id: object.id)}
  end
end
