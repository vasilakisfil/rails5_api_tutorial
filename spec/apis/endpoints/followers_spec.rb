require 'rails_helper'

describe Api::V1::FollowersController, type: :api do
  context :index do
    before do
      user = FactoryGirl.create(:user)

      5.times{ FactoryGirl.create(:relationship, followed: user) }

      get api_v1_user_followers_path(user_id: user.id)
    end

    it_returns_status(200)
  end

  context :destroy do
    before do
      user = FactoryGirl.create(:user)

      5.times{ FactoryGirl.create(:relationship, followed: user) }

      delete api_v1_user_follower_path(
        user_id: user.id, id: User.first!.followers.first.id
      )
    end

    it_returns_status(200)
  end
end

