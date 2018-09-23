class Api::V1::FeedsController < Api::V1::BaseController
  before_action :load_resource

  def show
    auth_microposts = policy_scope(@feed)

    render({
      json: SimpleAMS::Renderer::Collection.new(auth_microposts.collection, {
        serializer: Api::V1::MicropostSerializer,
        fields: auth_microposts.fields,
        expose: {current_user: current_user},
        collection: {
          metas: meta_attributes(auth_microposts.collection)
        }
      }).to_json,
    })
  end

  private
    def load_resource
      case params[:action].to_sym
      when :show
        @feed = paginate(User.find(params[:user_id]).feed)
      end
    end
end
