module ApiHelper
  include Rack::Test::Methods

  def app
    Rails.application
  end
end

RSpec.configure do |config|
  config.include ApiHelper, type: :api
  config.include Rails.application.routes.url_helpers, type: :api
end
