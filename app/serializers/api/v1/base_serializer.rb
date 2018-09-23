class Api::V1::BaseSerializer
  include SimpleAMS::DSL
  include Rails.application.routes.url_helpers

  adapter SimpleAMS::Adapters::JSONAPI, root: true, key_transform: :dash

  collection do
    meta :current_page
    meta :next_page
    meta :prev_page
    meta :total_count
    meta :total_pages


    link :self, ->(obj, s){ "http://localhost:3000/api/v1/users/?page%5Bnumber%5D=1&page%5Bsize%5D=25" }
    link :next, ->(obj, s){ "http://localhost:3000/api/v1/users/?page%5Bnumber%5D=2&page%5Bsize%5D=25" }
    link :last, ->(obj, s){ "http://localhost:3000/api/v1/users/?page%5Bnumber%5D=4&page%5Bsize%5D=25" }
  end

  def created_at
    object.created_at.to_datetime.in_time_zone('UTC').iso8601 if object.created_at
  end

  def updated_at
    object.updated_at.to_datetime.in_time_zone('UTC').iso8601 if object.updated_at
  end

  def reset_sent_at
    object.published_at.to_datetime.in_time_zone('UTC').iso8601 if object.reset_sent_at
  end
end
