class Api::V1::FollowingsController < Api::V1::BaseController
  before_action :load_resource

  def index
    auth_followings = policy_scope(@followings)

    render({
      json: SimpleAMS::Renderer::Collection.new(auth_followings.collection, {
        serializer: Api::V1::UserSerializer,
        fields: auth_followings.fields,
        expose: {current_user: current_user},
        include: [],
        collection: {
          metas: meta_attributes(auth_followings.collection)
        }
      }).to_json,
    })
  end

  #follow a user
  def create
    auth_following = FollowingPolicy.new(current_user, @relationship).create?
      
    @relationship.save!

    render({
      json: SimpleAMS::Renderer.new(auth_following.record, {
        serializer: Api::V1::UserSerializer,
        expose: {current_user: current_user}
      }).to_json
    })
  end

  #unfollow a user
  def destroy
    auth_following = FollowingPolicy.new(current_user, @relationship).destroy?
      
    @relationship.destroy!

    render({
      json: SimpleAMS::Renderer.new(auth_following.record, {
        serializer: Api::V1::UserSerializer,
        expose: {current_user: current_user}
      }).to_json
    })
  end

  private
  def load_resource
    case params[:action].to_sym
    when :index
      @followings = paginate(
        apply_filters(User.find(params[:user_id]).following, params)
      )
    when :create
      @relationship = Relationship.new(
        follower_id: params[:user_id],
        followed_id: params[:id]
      )
    when :destroy
      @relationship = Relationship.find_by!(
        follower_id: params[:user_id],
        followed_id: params[:id]
      )
    end
  end
end
