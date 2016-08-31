class Api::V1::BaseController < ActionController::Base
  ALLOWED_ORIGINS = %w{
    http://localhost:4200
  }.freeze

  include Pundit
  include ActiveHashRelation
  include CustomErrors

  protect_from_forgery with: :null_session
  before_action :destroy_session
  before_action :authenticate_user!, except: :options
  after_action :set_access_control_headers

  rescue_from ActionController::ParameterMissing do
    api_error(status: 400, errors: 'Invalid parameters')
  end

  rescue_from Pundit::NotAuthorizedError do
  end

  rescue_from ActiveRecord::RecordNotFound do
  end

  rescue_from UnauthenticatedError do
    unauthenticated!
  end

  protected
    def destroy_session
      request.session_options[:skip] = true
    end

    def current_user
      @current_user
    end

    def authenticate_user!
      token, options = ActionController::HttpAuthentication::Token.token_and_options(
        request
      )

      user_email = options.blank?? nil : options[:email]
      user = user_email && User.find_by(email: user_email)

      if user && ActiveSupport::SecurityUtils.secure_compare(
          user.token, token
      )
        @current_user = user
      else
        raise UnauthenticatedError
      end
    end

    def unauthorized!
      unless Rails.env.production? || Rails.env.test?
        Rails.logger.warn { "unauthorized for: #{current_user.try(:id)}" }
      end

      api_error(status: 403, errors: 'Not Authorized')
    end

    def unauthenticated!
      unless Rails.env.production? || Rails.env.test?
        Rails.logger.warn { "Unauthenticated user not granted access" }
      end

      api_error(status: 401, errors: 'Not Authenticated')
    end

    def not_found!
      Rails.logger.warn { "not_found for: #{current_user.try(:id)}" }

      api_error(status: 404, errors: 'Resource not found')
    end

    def invalid_resource!(errors = [])
      api_error(status: 422, errors: errors)
    end

    def paginate(resource)
      default_per_page = Rails.application.secrets.default_per_page || 25

      resource.paginate({
        page: params[:page] || 1, per_page: params[:per_page] || default_per_page
      })
    end

    #expects pagination!
    def meta_attributes(resource, extra_meta = {})

      meta = {
        current_page: resource.current_page,
        next_page: resource.next_page,
        prev_page: resource.previous_page,
        total_pages: resource.total_pages,
        total_count: resource.total_entries
      }.merge(extra_meta)

      return meta
    end

    def api_error(status: 500, errors: [])
      puts errors.full_messages if errors.respond_to?(:full_messages)

      set_access_control_headers

      render json: Api::V1::ErrorSerializer.new(status, errors).as_json,
        status: status
    end

  private
    def set_access_control_headers
      headers['Access-Control-Allow-Origin'] = ALLOWED_ORIGINS.select{
        |o| o == request.env['HTTP_ORIGIN']
      }.first
      headers['Access-Control-Allow-Methods'] = 'POST, PUT, PATCH, GET, DELETE, OPTIONS'
      headers['Access-Control-Max-Age'] = '1000'
      headers['Access-Control-Allow-Headers'] = 'Authorization, Content-Type'
    end
end
