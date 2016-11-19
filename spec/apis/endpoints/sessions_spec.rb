require 'rails_helper'

describe Api::V1::SessionsController, type: :api do
  context :create do
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
  end
end
