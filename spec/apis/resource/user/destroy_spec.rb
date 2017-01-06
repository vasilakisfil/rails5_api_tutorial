require 'rails_helper'

describe Api::V1::UsersController, type: :api do
  context :destroy do
    context 'when authenticated as a guest' do
      before do
        @user = FactoryGirl.create(:user)

        delete api_v1_user_path(@user.id)
      end

      it_returns_status(401)
      it_follows_json_schema('errors')
    end

    context 'when authenticated as a regular user' do
      before do
        create_and_sign_in_user
        @user = FactoryGirl.create(:user)

        delete api_v1_user_path(@user.id)
      end

      it_returns_status(200)
      it_follows_json_schema('regular/user')
      it_returns_attribute_values(
        resource: 'user', model: proc{@user}, attrs: [
          :id, :name, :email, :created_at
        ], modifiers: {
          created_at: proc{|i| i.in_time_zone('UTC').iso8601.to_s},
          id: proc{|i| i.to_s}
        }
      )
    end

    context 'when authenticated as an admin' do
      before do
        create_and_sign_in_admin
        @user = FactoryGirl.create(:user)

        delete api_v1_user_path(@user.id)
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
