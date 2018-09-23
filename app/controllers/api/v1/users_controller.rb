class Api::V1::UsersController < Api::V1::BaseController
  before_action :load_resource
  skip_before_action :authenticate_user!, only: [:index, :show, :create, :activate]
  before_action :authenticate_user, only: [:index, :show]

  def index
    auth_users = policy_scope(@users)

    render({
      json: SimpleAMS::Renderer::Collection.new(auth_users.collection, {
        serializer: Api::V1::UserSerializer,
        fields: auth_users.fields,
        expose: {current_user: current_user},
        collection: {
          metas: meta_attributes(auth_users.collection)
        }
      }).to_json,
    })
  end

  def show
    auth_user = authorize_with_permissions(@user)

    render({
      json: SimpleAMS::Renderer.new(auth_user.record, {
        serializer: Api::V1::UserSerializer,
        includes: [],
        fields: auth_user.fields,
        expose: {current_user: current_user}
      }).to_json
    })
  end

  def create
    auth_user = authorize_with_permissions(@user)

    if @user.save && @user.send_activation_email(ember_url: true) && @user.activate
      render({
        json: SimpleAMS::Renderer.new(auth_user.record, {
          serializer: Api::V1::UserSerializer,
          fields: auth_user.fields,
          expose: {current_user: current_user}
        }).to_json,
        status: 201
      })
    else
      invalid_resource!(@user.errors)
    end
  end

  def update
    auth_user = authorize_with_permissions(@user, :update?)

    if @user.update(update_params)
      render({
        json: SimpleAMS::Renderer.new(auth_user.record, {
          serializer: Api::V1::UserSerializer,
          fields: auth_user.fields,
          expose: {current_user: current_user}
        }).to_json
      })
    else
      invalid_resource!(@user.errors)
    end
  end

  def destroy
    auth_user = authorize_with_permissions(@user, :destroy?)

    @user.destroy!

    render({
      json: SimpleAMS::Renderer.new(auth_user.record, {
        serializer: Api::V1::UserSerializer,
        fields: auth_user.fields,
        expose: {current_user: current_user}
      }).to_json
    })
  end

  def activate
    auth_user = authorize_with_permissions(@user, :activate?)

    if @user.authenticated?(:activation, params[:token])
      render({
        json: SimpleAMS::Renderer.new(auth_user.record, {
          serializer: Api::V1::UserSerializer,
          fields: auth_user.fields,
          expose: {current_user: current_user}
        }).to_json
      })
    else
      not_found!
    end
  end

  private
    def load_resource
      case params[:action].to_sym
      when :index
        @users = paginate(apply_filters(User.all, params))
      when :create
        @user = User.new(create_params)
      when :show, :update, :destroy
        @user = User.find(params[:id])
      when :activate
        @user = User.find_by!(email: params[:email])
      end
    end

    def create_params
      normalized_params.permit(
        :email, :password, :password_confirmation, :name
      )
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
