require 'rails_helper'

describe Api::V1::UsersController, '#create', type: :api do
  describe 'Authorization' do
    context 'when not authenticated' do
      before do
        user = FactoryGirl.attributes_for(:user)
        post api_v1_users_path, jsonapi_style(user: user.as_json)
      end

      it_returns_status(201)
      it_follows_json_schema('regular/user')
    end

    context 'when authenticated as a regular user' do
      before do
        create_and_sign_in_user
        @user = FactoryGirl.attributes_for(:user)

        post api_v1_users_path, jsonapi_style(user: @user.as_json)
      end

      it_returns_status(201)
      it_follows_json_schema('regular/user')
      it_returns_attribute_values(
        resource: 'user', model: proc{@user}, attrs: [
          :name, :email
        ]
      )
    end

    context 'when authenticated as an admin' do
      before do
        create_and_sign_in_admin
        @user = FactoryGirl.attributes_for(:user)

        post api_v1_users_path, jsonapi_style(user: @user.as_json)
      end

      it_returns_status(201)
      it_follows_json_schema('regular/user')
      it_returns_attribute_values(
        resource: 'user', model: proc{@user}, attrs: [
          :name, :email
        ]
      )
    end
  end
end
