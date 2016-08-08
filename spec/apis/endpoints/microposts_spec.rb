require 'rails_helper'

describe Api::V1::MicropostsController, type: :api do
  context :index do
    before do
      5.times{ FactoryGirl.create(:micropost) }

      get api_v1_microposts_path, format: :json
    end

    it_returns_status(200)
  end

  context :create do
    before do
      #create_and_sign_in_micropost
      user = FactoryGirl.create(:user)
      @micropost = FactoryGirl.attributes_for(:micropost).merge(
        user_id: user.id
      )
      post api_v1_microposts_path, micropost: @micropost.as_json
    end

    it_returns_status(201)
  end

  context :show do
    before do
      #create_and_sign_in_micropost
      FactoryGirl.create(:micropost)
      @micropost = Micropost.last!

      get api_v1_micropost_path(@micropost.id)
    end

    it_returns_status(200)
  end

  context :update do
    before do
      #create_and_sign_in_micropost
      FactoryGirl.create(:micropost)
      @micropost = Micropost.last!
      @micropost.content = 'Something else'

      put api_v1_micropost_path(@micropost.id), micropost: @micropost.as_json
    end

    it_returns_status(200)
  end

  context :destroy do
    before do
      #create_and_sign_in_micropost
      @micropost = FactoryGirl.create(:micropost)

      delete api_v1_micropost_path(@micropost.id)
    end

    it_returns_status(200)
  end
end

