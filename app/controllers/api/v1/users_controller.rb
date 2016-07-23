class Api::V1::UsersController < Api::V1::BaseController
  before_action :load_resource

  def index
    auth_users = policy_scope(@users)

    render json: auth_users.collection,
      each_serializer: UserSerializer,
      fields: {users: auth_users.fields(params[:fields])},
      include: { users: auth_users.includes(params[:include]) },
      meta: meta_attributes(auth_users.collection)
  end

  def show
    auth_user = authorize_with_permissions(@user)

    render json: auth_user.record, serializer: UserSerializer,
      fields: {users: auth_user.fields(params[:fields])},
      include: { users: auth_user.includes(params[:include]) }
  end

  def create
    auth_user = authorize_with_permissions(@user)

    if @user.save
      render json: auth_user.record, serializer: UserSerializer, status: 201,
        fields: {users: auth_user.fields(params[:fields])},
        include: { users: auth_user.includes(params[:include]) }
    else
      invalid_resource!(@user.errors)
    end
  end

  def update
    auth_user = authorize_with_permissions(@user, :update?)

    if @user.update(update_params)
      render json: auth_user.record, serializer: UserSerializer,
        fields: {users: auth_user.fields(params[:fields])},
        include: { users: auth_user.includes(params[:include]) }
    else
      invalid_resource!(@user.errors)
    end
  end

  def destroy
    auth_user = authorize_with_permissions(@user, :destroy?)

    @user.destroy!

    render json: auth_user.record, serializer: UserSerializer,
        fields: {users: auth_user.fields(params[:fields])},
        include: { users: auth_user.includes(params[:include]) }
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
    end
  end

  def create_params
    params.require(:user).permit(
      :email, :password, :password_confirmation, :name
    )
  end
  def update_params
    create_params
  end
end
