# spec/system/users_withdraw_spec.rb
require 'rails_helper'

RSpec.describe "User withdrawal(system)", type: :system do
  let(:user) { FactoryBot.create(:user) }

  # JS不要なので rack_test ドライバを利用
  before do
    driven_by(:rack_test)
  end

  scenario "退会後は同じアカウントでログインできない" do
    # --- まず通常ログイン ---
    visit new_user_session_path

    fill_in "Email",    with: user.email
    fill_in "Password", with: "password"
    click_button "Log in"

    # --- 退会処理を直接叩く ---
    page.driver.submit :patch, withdraw_user_path(user), {}

    # DB 上のステータスが「withdrawn」になっていること（enum のキー）
    user.reload
    expect(user.status).to eq "withdrawn"

    # --- 退会済みアカウントで再ログインを試みる ---
    visit new_user_session_path
    fill_in "Email",    with: user.email
    fill_in "Password", with: "password"
    click_button "Log in"

    # サインイン画面に留まっている = ログインが成功していないこと
    expect(page).to have_current_path new_user_session_path
    # もし退会専用メッセージを出しているなら、ここで検証してもOK
    # expect(page).to have_content "退会済みのアカウントです"
  end
end
