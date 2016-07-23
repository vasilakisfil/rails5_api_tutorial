class Api::V1::SessionsController < Api::V1::BaseController
  before_action :load_resource

  def create
    if @user&.authenticate(create_params[:password])
      render(
        json: @user,
        serializer: Api::V1::SessionSerializer,
        status: 201
      )
    else
      return api_error(status: 401)
    end
  end

  private
  def create_params
    params.permit(:email, :password)
  end

  def load_resource
    case params[:action].to_sym
    when :create
      @user = User.find_by(email: create_params[:email])
    end
  end
end
