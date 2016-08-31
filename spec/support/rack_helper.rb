module RackHelper
  include Rack::Test::Methods

  def app
    Rails.application
  end
end

RSpec.configure do |config|
  config.include RackHelper, type: :api
  config.include Rails.application.routes.url_helpers, type: :api
end
