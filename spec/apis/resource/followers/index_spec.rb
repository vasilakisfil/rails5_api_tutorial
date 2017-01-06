require 'rails_helper'

describe Api::V1::FollowersController, '#index', type: :api do
  describe 'Authorization' do
    context 'when not authenticated' do
      before do
        user = FactoryGirl.create(:user)
        5.times{ FactoryGirl.create(:relationship, followed: user) }

        get api_v1_user_followers_path(user_id: user.id)
      end

      it_returns_status(401)
      it_follows_json_schema('errors')
    end

    context 'when authenticated as a regular user' do
      before do
        @user = FactoryGirl.create(:user)
        5.times{ FactoryGirl.create(:relationship, followed: @user) }
        create_and_sign_in_user

        get api_v1_user_followers_path(user_id: @user.id)
      end

      it_returns_status(200)
      it_follows_json_schema('regular/users')
      it_returns_collection_size(resource: 'users', size: 5)

      it_returns_collection_attribute_values(
        resource: 'users', model: proc{@user.followers.first!}, attrs: [
          :id, :name, :created_at, :microposts_count, :followers_count,
          :followings_count
        ],
        modifiers: {
          [:created_at] => proc{|i| i.iso8601},
          id: proc{|i| i.to_s}
        }
      )
    end
  end
end
