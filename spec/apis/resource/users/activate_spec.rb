require 'rails_helper'

describe Api::V1::UsersController, '#activate', type: :api do
  describe 'Authorization' do
    context 'when not authenticated' do
      context 'with correct token' do
        before do
          @user = FactoryGirl.create(:user)

          post activate_api_v1_users_path(email: @user.email, token: @user.activation_token)
        end

        it_returns_status(200)
        it_follows_json_schema('regular/user')
        it_returns_attribute_values(
          resource: 'user', model: proc{@user}, attrs: [
            :name, :email
          ]
        )
      end

      context 'with wrong token' do
        before do
          @user = FactoryGirl.create(:user)

          post activate_api_v1_users_path(email: @user.email, token: 'allo?')
        end

        it_returns_status(404)
        it_follows_json_schema('errors')
      end
    end

    context 'when authenticated as a regular user' do
      before do
        create_and_sign_in_user
        @user = FactoryGirl.create(:user)

        post activate_api_v1_users_path(email: @user.email, token: @user.activation_token)
      end

      it_returns_status(200)
      it_follows_json_schema('regular/user')
      it_returns_attribute_values(
        resource: 'user', model: proc{@user}, attrs: [
          :name, :email
        ]
      )
    end
  end
end
