Rails.application.routes.draw do
  # 認証用
  devise_for :users, controllers: {
    registrations: 'public/users/registrations',
    sessions: 'public/users/sessions'
  }
  
   # Public（URLに /public を付けない。Controller は Public::）
  scope module: :public do
    root 'homes#top'
    
    # ユーザーマイページ系
    resources :users, only: [:show, :edit, :update] do
      member { patch :withdraw }
    end

    # 家族とプロフィール（ユーザー1任につき家族1つ想定なので単数resource）
    resource :family, only: [:show, :edit, :update] do
      resources :profiles
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
  