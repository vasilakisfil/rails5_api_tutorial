class Api::V1::MicropostsController < Api::V1::BaseController
  before_action :load_resource

  def index
    auth_microposts = policy_scope(@microposts)

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

  def show
    auth_micropost = authorize_with_permissions(@micropost)

    render({
      json: SimpleAMS::Renderer.new(auth_micropost.record, {
        serializer: Api::V1::MicropostSerializer,
        fields: auth_micropost.fields,
        expose: {current_user: current_user}
      }).to_json
    })
  end

  def create
    auth_micropost = authorize_with_permissions(@micropost)

    if @micropost.save
      render({
        json: SimpleAMS::Renderer.new(auth_micropost.record, {
          serializer: Api::V1::MicropostSerializer,
          fields: auth_micropost.fields,
          expose: {current_user: current_user}
        }).to_json,
        status: 201
      })
    else
      invalid_resource!(@micropost.errors)
    end
  end

  def update
    auth_micropost = authorize_with_permissions(@micropost, :update?)

    if @micropost.update(update_params)
      render({
        json: SimpleAMS::Renderer.new(auth_micropost.record, {
          serializer: Api::V1::MicropostSerializer,
          fields: auth_micropost.fields,
          expose: {current_user: current_user}
        }).to_json
      })
    else
      invalid_resource!(@micropost.errors)
    end
  end

  def destroy
    auth_micropost = authorize_with_permissions(@micropost, :destroy?)

    @micropost.destroy!

    render({
      json: SimpleAMS::Renderer.new(auth_micropost.record, {
        serializer: Api::V1::MicropostSerializer,
        fields: auth_micropost.fields,
        expose: {current_user: current_user}
      }).to_json
    })
  end

  private
    def load_resource
      case params[:action].to_sym
      when :index
        @microposts = paginate(apply_filters(Micropost.all, params))
      when :create
        @micropost = Micropost.new(create_params)
      when :show, :update, :destroy
        @micropost = Micropost.find(params[:id])
      end
    end

    def create_params
      prms = normalized_params.permit(
        :content, :picture, :user_id
      )
      if prms[:user_id].nil? && params[:action].to_sym == :create
        prms[:user_id] = current_user&.id
      end

      return prms
    end

    def update_params
      create_params
    end

    def normalized_params
      ActionController::Parameters.new(
         ActiveModelSerializers::Deserialization.jsonapi_parse(params)
      )
    end
end
