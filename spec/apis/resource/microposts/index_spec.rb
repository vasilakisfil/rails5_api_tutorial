require 'rails_helper'

describe Api::V1::MicropostsController, '#index', type: :api do
  describe 'Authorization' do
    context 'when not authenticated' do
      before do
        5.times{ FactoryGirl.create(:micropost) }

        get api_v1_microposts_path, format: :json
      end

      it_returns_status(401)
      it_follows_json_schema('errors')
    end

    context 'when authenticated as a regular user' do
      before do
        create_and_sign_in_user
        5.times{ FactoryGirl.create(:micropost) }

        get api_v1_microposts_path, format: :json
      end

      it_returns_status(200)
      it_follows_json_schema('regular/microposts')
    end

    context 'when authenticated as an admin' do
      before do
        create_and_sign_in_admin_user
        5.times{ FactoryGirl.create(:micropost) }

        get api_v1_microposts_path, format: :json
      end

      it_returns_status(200)
      it_follows_json_schema('admin/microposts')
    end
  end
end
