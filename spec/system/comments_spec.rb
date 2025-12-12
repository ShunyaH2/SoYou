# spec/system/comments_spec.rb
require 'rails_helper'

RSpec.describe "Comments(system)", type: :system do
  before do
    skip 'Cloud9ではchromedriverが動かないためスキップ'
  end
  
  let(:user) { FactoryBot.create(:user) }

  # Post を作るときに TagGenerator が走るので、モックする
  before do
    dummy = instance_double(TagGenerator, assign_tags!: true)
    allow(TagGenerator).to receive(:new).and_return(dummy)
  end

  let!(:post_record) { FactoryBot.create(:post, user: user) }

  scenario "ユーザーがログインして投稿詳細からコメントを投稿し、画面に表示される", js: true do
    # --- ログイン ---
    visit new_user_session_path

    # ヘッダーが折りたたまれないように画面サイズを広げる
    page.current_window.resize_to(1920, 1080)

    fill_in "Email",    with: user.email
    fill_in "Password", with: "password"
    click_button "Log in"

    # --- 投稿詳細ページへ ---
    visit post_path(post_record)

    # --- コメント投稿 ---
    # textarea[name="comment[body]"] を直接指定して値をセットする
    find('textarea[name="comment[body]"]').set("テストコメント")

    click_button "コメントする"

    # リダイレクト先が投稿詳細であること
    expect(current_path).to eq post_path(post_record)

    # フラッシュメッセージ（CommentsController#create の notice）
    expect(page).to have_content "コメントを投稿しました。"

    # コメント本文がページ上に表示されていること
    expect(page).to have_content "テストコメント"
  end
end
