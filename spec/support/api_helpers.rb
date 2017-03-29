module ApiHelpers
  def jsonapi_style(hash)
    resource_key = hash.first.first
    resource_attributes = hash.first.last

    return {
      data: {
        type: resource_key.to_s.pluralize,
        attributes: resource_attributes
      }
    }
  end
end

RSpec.configure do |config|
  config.include ApiHelpers, type: :api
end
