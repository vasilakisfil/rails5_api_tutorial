class Api::V1::SessionsController < Api::V1::BaseController
  before_action :load_resource
  skip_before_action :authenticate_user!, only: [:create]

  def create
    if @user
      render(
        jsonapi: @user, serializer: Api::V1::SessionSerializer,
        status: 201, include: [:user], scope: @user
      )
    else
      return api_error(status: 401, errors: 'Wrong password or username')
    end
  end

  def show
    authorize(@user)

    render(
      jsonapi: @user, serializer: Api::V1::SessionSerializer,
      status: 200, include: [:user], fields: {
        user: UserPolicy::Regular.new(@user).fields
      }
    )
  end

  private
    def create_params
      normalized_params.permit(:email, :password)
    end

    def load_resource
      case params[:action].to_sym
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
