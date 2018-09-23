class Api::V1::FollowersController < Api::V1::BaseController
  before_action :load_resource

  def index
    auth_followers = policy_scope(@followers)

    render({
      json: SimpleAMS::Renderer::Collection.new(auth_followers.collection, {
        serializer: Api::V1::UserSerializer,
        fields: auth_followers.fields,
        expose: {current_user: current_user},
        include: [],
        collection: {
          metas: meta_attributes(auth_followers.collection)
        }
      }).to_json,
    })
  end

  #remove a follower
  def destroy
    auth_follower = FollowerPolicy.new(current_user, @relationship).destroy?
      
    @relationship.destroy!

    render({
      json: SimpleAMS::Renderer.new(auth_follower.record, {
        serializer: Api::V1::UserSerializer,
        expose: {current_user: current_user}
      }).to_json
    })
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

