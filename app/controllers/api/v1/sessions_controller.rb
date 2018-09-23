class Api::V1::SessionsController < Api::V1::BaseController
  before_action :load_resource
  skip_before_action :authenticate_user!, only: [:create]

  def index
    render({
      json: SimpleAMS::Renderer::Collection.new([@user], {
       serializer: Api::V1::SessionSerializer,
       expose: {current_user: @user},
       include: [:user],
       fields: [
         :email, :token, :user_id, user: UserPolicy::Regular.new(@user).fields
       ]
     }).to_json,
    })
  end

  def create
    if @user
      render({
       json: SimpleAMS::Renderer.new(@user, {
         serializer: Api::V1::SessionSerializer,
         expose: {current_user: @user},
       }).to_json,
       status: 201
      })
    else
      return api_error(status: 401, errors: 'Wrong password or username')
    end
  end

  def show
    authorize(@user)

    render({
      json: SimpleAMS::Renderer.new(@user, {
        serializer: Api::V1::SessionSerializer,
        expose: {current_user: @user},
        include: [:user],
        fields: [
          :email, :token, :user_id, user: UserPolicy::Regular.new(@user).fields
        ]
      }).to_json,
    })
  end

  private
    def create_params
      normalized_params.permit(:email, :password)
    end

    def load_resource
      case params[:action].to_sym
      when :index
        @user = current_user
      when :create
        @user = User.find_by(
          email: create_params[:email]
        )&.authenticate(create_params[:password])
      when :show
        @user = User.find(params[:id])
      end
    end

    def normalized_params
      ActionController::Parameters.new(
         ActiveModelSerializers::Deserialization.jsonapi_parse(params)
      )
    end
end
