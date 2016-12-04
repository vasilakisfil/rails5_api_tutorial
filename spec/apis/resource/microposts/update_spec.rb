require 'rails_helper'

describe Api::V1::MicropostsController, '#update', type: :api do
  describe 'Authorization' do
    context 'when not authenticated' do
      before do
        micropost = FactoryGirl.create(:micropost)

        put api_v1_micropost_path(micropost), format: :json
      end

      it_returns_status(401)
      it_follows_json_schema('errors')
    end

    context 'when authenticated as a regular user' do
      before do
        create_and_sign_in_user
        micropost = FactoryGirl.create(:micropost)

        put api_v1_micropost_path(micropost), format: :json
      end

      it_returns_status(200)
      it_follows_json_schema('regular/micropost')
    end

    context 'when authenticated as an admin' do
      before do
        create_and_sign_in_admin
        micropost = FactoryGirl.create(:micropost)

        put api_v1_micropost_path(micropost), format: :json
      end

      it_returns_status(200)
      it_follows_json_schema('admin/micropost')
    end
  end
end
