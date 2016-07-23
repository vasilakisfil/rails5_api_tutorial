require 'rails_helper'

describe Api::V1::FollowingsController, type: :api do
  context :index do
    before do
      user = FactoryGirl.create(:user)

      5.times{ FactoryGirl.create(:relationship, follower: user) }

      get api_v1_user_followings_path(user_id: user.id)
    end

    it_returns_status(200)
  end

  context :destroy do
    before do
      user = FactoryGirl.create(:user)
      following = FactoryGirl.create(:user)

      post api_v1_user_following_path(
        user_id: user.id, id: following.id
      )
    end

    it_returns_status(200)
  end

  context :destroy do
    before do
      user = FactoryGirl.create(:user)

      5.times{ FactoryGirl.create(:relationship, follower: user) }

      delete api_v1_user_following_path(
        user_id: user.id, id: User.first!.following.first.id
      )
    end

    it_returns_status(200)
  end
end


