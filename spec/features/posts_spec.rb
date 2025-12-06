# spec/features/posts_spec.rb
require 'rails_helper'

RSpec.describe "Posts(feature)", type: :feature do
  let(:user) { FactoryBot.create(:user) }

  before do
    # TagGenerator が走ると外部APIに行ってしまうので常にモックしておく
    dummy = instance_double(TagGenerator, assign_tags!: true)
    allow(TagGenerator).to receive(:new).and_return(dummy)
  end

  scenario "ユーザーがログインして投稿を作成し、詳細画面を確認できる" do
    visit new_user_session_path

    fill_in "Email",    with: user.email
    fill_in "Password", with: "password"
    click_button "Log in"

    click_link "新規投稿" # 実際のリンクテキストに合わせて調整してください

    fill_in "出来事の日付", with: Date.current
    fill_in "エピソード本文", with: "フィーチャースペックのテスト投稿です"
    click_button "投稿する"

    expect(page).to have_content "投稿を作成しました。"
    expect(page).to have_content "フィーチャースペックのテスト投稿です"
  end

  scenario "family_admin は family 内の他ユーザー投稿も編集・削除できる" do
    admin  = FactoryBot.create(:user)                 # 1人目なので family_admin: true
    member = FactoryBot.create(:user, family: admin.family)
    post   = FactoryBot.create(:post, user: member)

    # ログイン
    visit new_user_session_path
    fill_in "Email",    with: admin.email
    fill_in "Password", with: "password"
    click_button "Log in"

    # メンバーの投稿詳細へ
    visit post_path(post)

    expect(page).to have_link "編集"
    expect(page).to have_link "削除"
  end

  scenario "family_admin でない family メンバーは、他ユーザー投稿の編集・削除はできない" do
    owner  = FactoryBot.create(:user)                   # family_admin: true
    member = FactoryBot.create(:user, family: owner.family) # 2人目 => non-admin
    post   = FactoryBot.create(:post, user: owner)

    # family_admin ではない側でログイン
    visit new_user_session_path
    fill_in "Email",    with: member.email
    fill_in "Password", with: "password"
    click_button "Log in"

    visit post_path(post)

    expect(page).not_to have_link "編集"
    expect(page).not_to have_link "削除"
  end

  scenario "投稿一覧で本文キーワード検索ができる（Ransack）" do
    # 検索対象データを用意
    post1 = FactoryBot.create(:post, user: user, body: "公園で遊んだエピソード")
    post2 = FactoryBot.create(:post, user: user, body: "図書館に行ったエピソード")

    # ログイン
    visit new_user_session_path
    fill_in "Email",    with: user.email
    fill_in "Password", with: "password"
    click_button "Log in"

    # 投稿一覧へ
    visit posts_path

    # Ransack の search_field :body_cont を想定
    # -> input の id は通常 "q_body_cont" になる
    fill_in "q_body_cont", with: "公園"

    # 検索ボタン（ビュー側の文言に合わせて必要なら調整）
    click_button "検索"

    # 「公園」を含む方だけ表示されていること
    expect(page).to have_content "公園で遊んだエピソード"
    expect(page).not_to have_content "図書館に行ったエピソード"
  end
end
