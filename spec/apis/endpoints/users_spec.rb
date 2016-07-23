require 'rails_helper'

describe Api::V1::UsersController, type: :api do
  context :index do
    before do
      5.times{ FactoryGirl.create(:user) }

      get api_v1_users_path, format: :json
    end

    it_returns_status(200)
  end

  context :create do
    before do
      #create_and_sign_in_user
      @user = FactoryGirl.attributes_for(:user)
      post api_v1_users_path, user: @user.as_json
    end

    it_returns_status(201)
  end

  context :show do
    before do
      #create_and_sign_in_user
      FactoryGirl.create(:user)
      @user = User.last!

      get api_v1_user_path(@user.id)
    end

    it_returns_status(200)
  end

  context :update do
    before do
      #create_and_sign_in_user
      FactoryGirl.create(:user)
      @user = User.last!
      @user.name = 'Something else'

      put api_v1_user_path(@user.id), user: @user.as_json
    end

    it_returns_status(200)
  end

  context :destroy do
    before do
      #create_and_sign_in_user
      @user = FactoryGirl.create(:user)

      delete api_v1_user_path(@user.id)
    end

    it_returns_status(200)
  end
end
