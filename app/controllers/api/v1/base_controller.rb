class Api::V1::BaseController < ActionController::API
  include Pundit
  include ActiveHashRelation
  include CustomErrors

  before_action :authenticate_user!, except: :options

  rescue_from ActionController::ParameterMissing do
    api_error(status: 400, errors: 'Invalid parameters')
  end

  rescue_from Pundit::NotAuthorizedError do
    unauthorized!
  end

  rescue_from ActiveRecord::RecordNotFound do
    api_error(status: 404, errors: 'Resource not found!')
  end

  rescue_from UnauthenticatedError do
    unauthenticated!
  end

  protected
    def current_user
      @current_user
    end

    def authenticate_user
      token, options = ActionController::HttpAuthentication::Token.token_and_options(
        request
      )

      return nil unless token && options.is_a?(Hash)

      user = User.find_by(email: options['email'])
      if user && ActiveSupport::SecurityUtils.secure_compare(user.token, token)
        @current_user = user
      else
        return nil
      end
    end

    def authenticate_user!
      authenticate_user or raise UnauthenticatedError
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

    #expects paginated resource!
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

      render json: Api::V1::ErrorSerializer.new(status, errors).as_json,
        status: status
    end
end
