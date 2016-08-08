class Api::V1::MicropostsController < Api::V1::BaseController
  before_action :load_resource

  def index
    auth_microposts = policy_scope(@microposts)

    render json: auth_microposts.collection,
      each_serializer: MicropostSerializer,
      fields: { microposts: auth_microposts.fields(params[:fields])},
      include: { microposts: auth_microposts.includes(params[:include]) },
      meta: meta_attributes(auth_microposts.collection)
  end

  def show
    auth_micropost = authorize_with_permissions(@micropost)

    render json: auth_micropost.record, serializer: MicropostSerializer,
      fields: { microposts: auth_micropost.fields(params[:fields]) },
      include: { microposts: auth_micropost.includes(params[:include]) }
  end

  def create
    auth_micropost = authorize_with_permissions(@micropost)

    if @micropost.save
      render json: auth_micropost.record, serializer: MicropostSerializer, status: 201,
        fields: { microposts: auth_micropost.fields(params[:fields]) },
        include: { microposts: auth_micropost.includes(params[:include]) }
    else
      invalid_resource!(@micropost.errors)
    end
  end

  def update
    auth_micropost = authorize_with_permissions(@micropost, :update?)

    if @micropost.update(update_params)
      render json: auth_micropost.record, serializer: MicropostSerializer,
        fields: { microposts: auth_micropost.fields(params[:fields]) },
        include: { microposts: auth_micropost.includes(params[:include]) }
    else
      invalid_resource!(@micropost.errors)
    end
  end

  def destroy
    auth_micropost = authorize_with_permissions(@micropost, :destroy?)

    @micropost.destroy!

    render json: auth_micropost.record, serializer: MicropostSerializer,
      fields: { microposts: auth_micropost.fields(params[:fields]) },
      include: { microposts: auth_micropost.includes(params[:include]) }
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
    prms = params.require(:micropost).permit(
      :content, :picture, :user_id
    )
    prms[:user_id] = current_user&.id if prms[:user_id].nil?

    return prms
  end
  def update_params
    create_params
  end
end
