require 'rails_helper'

describe Api::V1::MicropostsController, '#create', type: :api do
  describe 'Authorization' do
    context 'when not authenticated' do
      before do
        user = FactoryGirl.create(:user)
        micropost = FactoryGirl.attributes_for(:micropost).merge(user_id: user.id)

        post api_v1_microposts_path, jsonapi_style(micropost: micropost.as_json)
      end

      it_returns_status(401)
      it_follows_json_schema('errors')
    end

    context 'when authenticated as a regular user' do
      before do
        user = create_and_sign_in_user
        @micropost = FactoryGirl.attributes_for(:micropost).merge(user_id: user.id)

        post api_v1_microposts_path, jsonapi_style(micropost: @micropost.as_json)
      end

      it_returns_status(201)
      it_follows_json_schema('regular/micropost')

      it_returns_attribute_values(
        resource: 'micropost', model: proc{@micropost}, attrs: [
          :content, :user_id
        ]
      )
    end

    context 'when authenticated as an admin' do
      before do
        user = create_and_sign_in_admin
        @micropost = FactoryGirl.attributes_for(:micropost).merge(user_id: user.id)

        post api_v1_microposts_path, jsonapi_style(micropost: @micropost.as_json)
      end

      it_returns_status(201)
      it_follows_json_schema('admin/micropost')

      it_returns_attribute_values(
        resource: 'micropost', model: proc{@micropost}, attrs: [
          :content, :user_id
        ]
      )
    end
  end
end


