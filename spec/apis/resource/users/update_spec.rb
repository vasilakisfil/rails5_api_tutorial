require 'rails_helper'

describe Api::V1::UsersController, '#update', type: :api do
  describe 'Authorization' do
    context 'when authenticated as a guest user' do
      before do
        FactoryGirl.create(:user)
        @user = User.last!
        @user.name = 'Something else'

        put api_v1_user_path(@user.id), jsonapi_style(user: @user.as_json)
      end

      it_returns_status(401)
      it_follows_json_schema('errors')
    end

    context 'when authenticated as a regular user' do
      before do
        create_and_sign_in_user
        FactoryGirl.create(:user)
        @user = User.last!
        @user.name = 'Something else'

        put api_v1_user_path(@user.id), jsonapi_style(user: @user.as_json)
      end

      it_returns_status(200)
      it_follows_json_schema('regular/user')
      it_returns_attribute_values(
        resource: 'user', model: proc{@user}, attrs: [
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
        create_and_sign_in_admin
        FactoryGirl.create(:user)
        @user = User.last!
        @user.name = 'Something else'

        put api_v1_user_path(@user.id), jsonapi_style(user: @user.as_json)
      end

      it_returns_status(200)
      it_follows_json_schema('admin/user')
      it_returns_attribute_values(
        resource: 'user', model: proc{@user}, attrs: User.column_names,
        modifiers: {
          [:created_at, :updated_at] => proc{|i| i.in_time_zone('UTC').iso8601.to_s},
          id: proc{|i| i.to_s}
        }
      )
    end
  end
end
