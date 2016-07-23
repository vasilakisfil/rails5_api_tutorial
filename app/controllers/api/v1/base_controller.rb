class Api::V1::BaseController < ApplicationController
  include Pundit
  include ActiveHashRelation

  protect_from_forgery with: :null_session
  before_action :destroy_session

  rescue_from ActionController::ParameterMissing do
    api_error(status: 400, errors: 'Invalid parameters')
  end

  rescue_from Pundit::NotAuthorizedError do
    unauthorized!
  end

  rescue_from ActiveRecord::RecordNotFound do
    not_found!
  end

  protected
    def destroy_session
      request.session_options[:skip] = true
    end

    def unauthorized!
      unless Rails.env.production? || Rails.env.test?
        Rails.logger.warn { "unauthorized for: #{current_user.try(:id)}" }
      end

      api_error(status: 403, errors: 'Not Authorized')
    end

    def not_found!
      Rails.logger.warn { "not_found for: #{current_user.try(:id)}" }

      api_error(status: 404, errors: 'Resource not found')
    end

    def invalid_resource!(errors = [])
      api_error(status: 422, errors: errors)
    end

    def paginate(resource)
      default_per_page = Rails.application.secrets.default_per_page || 10

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

      render json: errors.as_json, status: status
    end
end

