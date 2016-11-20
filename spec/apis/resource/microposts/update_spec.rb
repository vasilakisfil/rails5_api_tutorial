require 'rails_helper'

describe Api::V1::MicropostsController, '#update', type: :api do
  describe 'Authorization' do
    context 'when not authenticated' do
      before do
        micropost = FactoryGirl.create(:micropost)

        put api_v1_micropost_path(micropost), format: :json
      end

      it_returns_status(401)
      it_follows_json_schema('errors')
    end

    context 'when authenticated as a regular user' do
      before do
        create_and_sign_in_user
        @micropost = FactoryGirl.create(:micropost)

        put api_v1_micropost_path(@micropost), format: :json
      end

      it_returns_status(200)
      it_follows_json_schema('regular/micropost')
      it_returns_attribute_values(
        resource: 'micropost', model: proc{@micropost}, attrs: [
          :id, :content, :user_id, :created_at, :updated_at
        ],
        modifiers: {
          [:created_at, :updated_at] => proc{|i| i.in_time_zone('UTC').iso8601.to_s},
          id: proc{|i| i.to_s}
        }
      )
    end

    context 'when authenticated as an admin' do
      before do
        create_and_sign_in_admin
        @micropost = FactoryGirl.create(:micropost)

        put api_v1_micropost_path(@micropost), format: :json
      end

      it_returns_status(200)
      it_follows_json_schema('admin/micropost')
      it_returns_attribute_values(
        resource: 'micropost', model: proc{@micropost}, attrs: [
          :id, :content, :user_id, :created_at, :updated_at
        ],
        modifiers: {
          [:created_at, :updated_at] => proc{|i| i.in_time_zone('UTC').iso8601.to_s},
          id: proc{|i| i.to_s}
        }
      )
    end
  end
end
