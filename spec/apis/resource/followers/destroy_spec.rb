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

        delete api_v1_user_follower_path(
          user_id: user.id, id: User.first!.followers.first.id
        )
      end

      it_returns_status(403)
      it_follows_json_schema('errors')
    end
  end
end

