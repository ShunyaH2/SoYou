Rails.application.routes.draw do
  namespace :public do
    get 'users/show'
    get 'users/edit'
  end
  devise_for :users # 認証用
  
  # Public（URLに /public を付けない。Controller は Public::）
  scope module: :public do
    root 'homes#top'

    resources :users, only: [:show, :edit, :update] do
      member { patch :withdraw }
    end
    resources :posts
  end

   # Admin（URLに /admin を付ける。Controller は Admin::）
   namespace :admin do
    root 'dashbord#top'
    resources :users, only: [:index, :show, :update]
    resources :users, only: [:index, :show, :destroy]
   end
  end
  