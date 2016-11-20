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
    end
  end
end
