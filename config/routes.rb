Rails.application.routes.draw do
  # --- Public（エンドユーザー） ---
  devise_for :users, controllers: {
    registrations: 'public/users/registrations',
    sessions:      'public/users/sessions'
  }

  # --- Admin 認証（モデルは AdminUser、URL は /admin/*）---
  devise_for :admin,
  class_name: 'AdminUser',
  path: 'admin',
  skip: [:registrations, :passwords], 
  controllers: {sessions: 'admin/admin_users/sessions' }

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
      resources :comments, only: [:create, :edit, :update, :destroy]  
    end
  end


  
  # --- Admin 画面 ---
  namespace :admin do
    root 'dashboard#top'
    resources :users, only: [:index, :show, :update, :destroy] do
      member do
        patch :promote_family_admin   # 家族管理者にする
        patch :demote_family_admin    # 一般ユーザーに戻す
      end
    end
    resources :posts,    only: [:index, :show, :edit, :update, :destroy]
    resources :profiles, only: [:index, :destroy]
    resources :comments, only: [:index, :destroy]
    resources :tags,     only: [:index, :edit, :update, :destroy, :new, :create] do
      patch :restore, on: :member
    end
  end
end