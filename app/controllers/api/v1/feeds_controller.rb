class Api::V1::FeedsController < Api::V1::BaseController
  before_action :load_resource

  def show
    auth_microposts = policy_scope(@feed)

    render jsonapi: auth_microposts.collection,
      each_serializer: Api::V1::MicropostSerializer,
      fields: {micropost: auth_microposts.fields(params[:fields])},
      meta: meta_attributes(auth_microposts.collection)
  end

  private
    def load_resource
      case params[:action].to_sym
      when :show
        @feed = paginate(User.find(params[:user_id]).feed)
      end
    end
end
