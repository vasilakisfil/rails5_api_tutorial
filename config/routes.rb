Rails.application.routes.draw do
  root   'static_pages#home'
  get    '/help',    to: 'static_pages#help'
  get    '/about',   to: 'static_pages#about'
  get    '/contact', to: 'static_pages#contact'
  get    '/signup',  to: 'users#new'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  resources :users do
    member do
      get :following, :followers
    end
  end
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :microposts,          only: [:create, :destroy]
  resources :relationships,       only: [:create, :destroy]

  #api
  namespace :api do
    namespace :v1 do
      resources :sessions, only: [:create, :show]

      resources :users, only: [:index, :create, :show, :update, :destroy] do
        post :activate, on: :collection
        resources :followers, only: [:index, :destroy]
        resources :followings, only: [:index, :destroy] do
          post :create, on: :member
        end
        resource :feed, only: [:show]
      end
      resources :microposts, only: [:index, :create, :show, :update, :destroy]
    end
  end
end
