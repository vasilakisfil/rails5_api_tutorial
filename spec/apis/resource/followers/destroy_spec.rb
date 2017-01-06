require 'rails_helper'

describe Api::V1::FollowersController, '#destroy', type: :api do
  describe 'Authorization' do
    context 'when not authenticated' do
      before do
        user = FactoryGirl.create(:user)
        5.times{ FactoryGirl.create(:relationship, followed: user) }

        delete api_v1_user_follower_path(
          user_id: user.id, id: user.followers.first!.id
        )
      end

      it_returns_status(401)
      it_follows_json_schema('errors')
    end

    context 'when authenticated as not the owner' do
      before do
        user = FactoryGirl.create(:user)
        5.times{ FactoryGirl.create(:relationship, followed: user) }
        create_and_sign_in_user

        @follower = user.followers.first!

        delete api_v1_user_follower_path(
          user_id: user.id, id: @follower.id
        )
      end

      it_returns_status(403)
      it_follows_json_schema('errors')
    end

    context 'when autenticated as the owner' do
      before do
        user = create_and_sign_in_user
        5.times{ FactoryGirl.create(:relationship, followed: user) }

        @follower = user.followers.first!

        delete api_v1_user_follower_path(
          user_id: user.id, id: @follower.id
        )
      end

      it_returns_status(200)

      it_returns_attribute_values(
        resource: 'user', model: proc{@follower}, attrs: [
          :id, :name, :created_at, :microposts_count, :followers_count,
          :followings_count
        ],
        modifiers: {
          created_at: proc{|i| i.in_time_zone('UTC').iso8601.to_s},
          id: proc{|i| i.to_s},
          followings_count: proc{|i| i - 1}
        }
      )
    end
  end
end

