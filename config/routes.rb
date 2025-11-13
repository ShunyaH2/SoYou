Rails.application.routes.draw do
  # --- Public（エンドユーザー） ---
  devise_for :users, controllers: {
    registrations: 'public/users/registrations',
    sessions:      'public/users/sessions'
  }

  scope module: :public do
    root 'homes#top'

    resources :users, only: [:show, :edit, :update] do
      member do
        patch :promote_to_family_admin
        patch :demote_from_family_admin
      end
        patch :withdraw, on: :member
    end

    resource :family, only: [:show, :edit, :update] do
      resources :profiles
    end

    resources :posts do
      resources :comments, only: [:create, :destroy]  
    end
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
    resources :comments, only: [:index, :destroy]
    resources :tags,     only: [:index, :edit, :update, :destroy, :new, :create] do
      patch :restore, on: :member
    end
  end
end