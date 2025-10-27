Rails.application.routes.draw do
  # --- Public（エンドユーザー） ---
  devise_for :users, controllers: {
    registrations: 'public/users/registrations',
    sessions:      'public/users/sessions'
  }

  scope module: :public do
    root 'homes#top'

    resources :users, only: [:show, :edit, :update] do
      member { patch :withdraw }
    end

    resource :family, only: [:show, :edit, :update] do
      resources :profiles
    end

    resources :posts
  end

  # --- Admin 認証（モデルは AdminUser、URL は /admin/*）---
  devise_for :admin,
              class_name: 'AdminUser',
              path: 'admin',
              skip: [:registrations, :passwords], 
              controllers: {sessions: 'admin/admin_users/sessions' }
  
  # --- Admin 画面 ---
  namespace :admin do
    root 'dashboard#top'
    resources :users,    only: [:index, :show, :update, :destroy]
    resources :posts,    only: [:index, :show, :edit, :update, :destroy]
    resources :profiles, only: [:index, :destroy]
  end
end