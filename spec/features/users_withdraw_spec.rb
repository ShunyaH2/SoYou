# spec/features/users_withdraw_spec.rb
require 'rails_helper'

RSpec.describe "User withdrawal(feature)", type: :feature do
  scenario "退会後は同じアカウントでログインできない" do
    user = FactoryBot.create(:user)

    # まずログイン
    visit new_user_session_path
    fill_in "Email",    with: user.email
    fill_in "Password", with: "password"
    click_button "Log in"

    # 退会リクエストを発行（UIボタンを経由せず、直接パスに PATCH）
    page.driver.submit :patch, withdraw_user_path(user), {}

    # コントローラー仕様：
    # - status を withdrawn にする
    # - new_user_registration_path へリダイレクト
    expect(page).to have_current_path new_user_registration_path

    user.reload
    expect(user.status).to eq "withdrawn"

    # 同じアカウントで再ログインを試みる
    visit new_user_session_path
    fill_in "Email",    with: user.email
    fill_in "Password", with: "password"
    click_button "Log in"

    # Devise の active_for_authentication? によって認証不可のはず
    # -> サインイン画面に留まる想定
    expect(page).to have_current_path new_user_session_path
  end
end
