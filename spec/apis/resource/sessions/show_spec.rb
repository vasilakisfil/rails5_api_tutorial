require 'rails_helper'

describe Api::V1::SessionsController, '#show', type: :api do
  describe 'Authoriation' do
    context 'with wrong params' do
      before do
        user = FactoryGirl.create(:user, {
          password: 'foobar', password_confirmation: 'foobar'
        })

        get api_v1_session_path(user.id)

      end

      it_returns_status(401)
      it_follows_json_schema('errors')
    end

    context 'with correct params' do
      before do
        user = FactoryGirl.create(:user, {
          password: 'foobar', password_confirmation: 'foobar'
        })
        sign_in(user)

        get api_v1_session_path(user.id)
      end

      it_returns_status(200)
      it_follows_json_schema('regular/session')
    end
  end
end

