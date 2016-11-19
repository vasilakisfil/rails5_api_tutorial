class Api::V1::FollowersController < Api::V1::BaseController
  before_action :load_resource

  def index
    auth_followers = policy_scope(@followers)

    render jsonapi: auth_followers.collection,
      each_serializer: Api::V1::UserSerializer,
      fields: {users: auth_followers.fields(params[:fields]).concat(
        [:microposts, :followers, :followings]
      )},
      include: [],
      meta: meta_attributes(auth_followers.collection)
  end

  #remove a follower
  def destroy
    auth_follower = FollowerPolicy.new(current_user, @relationship).destroy?
      
    @relationship.destroy!

    render jsonapi: auth_follower.record, serializer: Api::V1::UserSerializer,
      fields: { users: auth_follower.fields(params[:fields])},
      include: []
  end

  private
  def load_resource
    case params[:action].to_sym
    when :index
      @followers = paginate(
        apply_filters(User.find(params[:user_id]).followers, params)
      )
    when :destroy
      @relationship = Relationship.find_by!(
        followed_id: params[:user_id],
        follower_id: params[:id]
      )
    end
  end
end

