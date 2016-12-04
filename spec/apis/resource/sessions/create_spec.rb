require 'rails_helper'

describe Api::V1::SessionsController, '#create', type: :api do
  describe 'Authoriation' do
    context 'with wrong params' do
      before do
        user = FactoryGirl.create(:user, {
          password: 'foobar', password_confirmation: nil
        })

        post api_v1_sessions_path(
          jsonapi_style(user: {email: user.email, password: 'foobar1'})
        )
      end

      it_returns_status(401)
    end

    context 'with correct params' do
      before do
        user = FactoryGirl.create(:user, {
          password: 'foobar', password_confirmation: nil
        })

        post api_v1_sessions_path(
          jsonapi_style(user: {email: user.email, password: 'foobar'})
        )
      end

      it_returns_status(201)
    end
  end
end
