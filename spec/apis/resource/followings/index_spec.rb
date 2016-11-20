require 'rails_helper'

describe Api::V1::FollowingsController, '#index', type: :api do
  describe 'Authorization' do
    context 'when not authenticated' do
      before do
        user = FactoryGirl.create(:user)
        5.times{ FactoryGirl.create(:relationship, follower: user) }

        get api_v1_user_followings_path(user_id: user.id)
      end

      it_returns_status(401)
      it_follows_json_schema('errors')
    end

    context 'when authenticated as a regular user' do
      before do
        user = FactoryGirl.create(:user)
        5.times{ FactoryGirl.create(:relationship, followed: user) }
        create_and_sign_in_user

        get api_v1_user_followings_path(user_id: user.id)
      end

      it_returns_status(200)
      it_follows_json_schema('regular/users')
    end
  end
end
