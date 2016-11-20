require 'rails_helper'

describe Api::V1::FollowingsController, '#create', type: :api do
  describe 'Authorization' do
    context 'when not authenticated' do
      before do
        user = FactoryGirl.create(:user)
        following = FactoryGirl.create(:user)

        post api_v1_user_following_path(
          user_id: user.id, id: following.id
        )
      end

      it_returns_status(401)
      it_follows_json_schema('errors')
    end

    context 'when authenticated as not the owner' do
      before do
        user = FactoryGirl.create(:user)
        following = FactoryGirl.create(:user)
        create_and_sign_in_user

        post api_v1_user_following_path(
          user_id: user.id, id: following.id
        )
      end

      it_returns_status(403)
      it_follows_json_schema('errors')
    end

    context 'when authenticated as the owner' do
      before do
        user = FactoryGirl.create(:user)
        @following = FactoryGirl.create(:user)
        sign_in(user)

        post api_v1_user_following_path(
          user_id: user.id, id: @following.id
        )
      end

      it_returns_status(200)
      it_follows_json_schema('regular/user')

      it_returns_attribute_values(
        resource: 'user', model: proc{@following}, attrs: [
          :id, :name, :created_at, :microposts_count, :followers_count,
          :followings_count
        ],
        modifiers: {
          created_at: proc{|i| i.in_time_zone('UTC').iso8601.to_s},
          id: proc{|i| i.to_s},
          followers_count: proc{|i| i + 1}
        }
      )
    end
  end
end

