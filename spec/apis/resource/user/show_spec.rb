require 'rails_helper'

describe Api::V1::UsersController, '#show', type: :api do
  describe 'Authorization' do
    context 'when as guest' do
      before do
        FactoryGirl.create(:user)
        @user = User.last!

        get api_v1_user_path(@user.id)
      end

      it_returns_status(401)
      it_follows_json_schema('errors')
    end

    context 'when authenticated as a regular user' do
      before do
        create_and_sign_in_user
        FactoryGirl.create(:user)
        @user = User.last!

        get api_v1_user_path(@user.id)
      end

      it_returns_status(200)
      it_follows_json_schema('regular/user')
    end

    context 'when authenticated as an admin' do
      before do
        create_and_sign_in_admin
        FactoryGirl.create(:user)
        @user = User.last!

        get api_v1_user_path(@user.id)
      end

      it_returns_status(200)
      it_follows_json_schema('admin/user')
    end
  end
end
