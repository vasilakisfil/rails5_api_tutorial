require 'rails_helper'

describe Api::V1::UsersController, '#index', type: :api do
  describe 'Authorization' do
    context 'when not authenticated' do
      before do
        5.times{ FactoryGirl.create(:user) }

        get api_v1_users_path, format: :json
      end

      it_returns_status(200)
      it_follows_json_schema('guest/users')
    end

    context 'when authenticated as a regular user' do
      before do
        create_and_sign_in_user
        5.times{ FactoryGirl.create(:user) }

        get api_v1_users_path, format: :json
      end

      it_returns_status(200)
      it_follows_json_schema('regular/users')
      it_returns_collection_size(resource: 'users', size: 5+1)

      it_returns_collection_attribute_values(
        resource: 'users', model: proc{User.first!}, attrs: [
          :id, :name, :created_at, :microposts_count, :followers_count,
          :followings_count
        ],
        modifiers: {
          created_at: proc{|i| i.in_time_zone('UTC').iso8601.to_s},
          id: proc{|i| i.to_s}
        }
      )
    end

    context 'when authenticated as an admin' do
      before do
        create_and_sign_in_admin_user
        5.times{ FactoryGirl.create(:user) }

        get api_v1_users_path, format: :json
      end

      it_returns_status(200)
      it_follows_json_schema('admin/users')
      it_returns_collection_size(resource: 'users', size: 5+1)

      it_returns_collection_attribute_values(
        resource: 'users', model: proc{User.first!}, attrs: User.column_names,
        modifiers: {
          [:created_at, :updated_at] => proc{|i| i.iso8601},
          id: proc{|i| i.to_s}
        }
      )
    end
  end
end
