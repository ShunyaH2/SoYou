require 'rails_helper'

RSpec.describe "Posts", type: :request do
  let(:user)        { FactoryBot.create(:user) }                          # family_admin: true（1人目）
  let(:other_user)  { FactoryBot.create(:user) }                          # 別 family
  let(:family_user) { FactoryBot.create(:user, family: user.family) }     # 同じ family だが admin ではない想定

  let!(:own_post)    { FactoryBot.create(:post, user: user) }
  let!(:others_post) { FactoryBot.create(:post, user: other_user) }
  let!(:family_post) { FactoryBot.create(:post, user: family_user) }

  # TagGenerator が本物のAPIを叩かないようにモック
  before do
    dummy = instance_double(TagGenerator, assign_tags!: true)
    allow(TagGenerator).to receive(:new).and_return(dummy)
  end

  # =========================
  # index
  # =========================
  describe "#index" do
    context "ユーザーがログインしている場合" do
      before do
        sign_in user
        get posts_path
      end

      it "ステータスが200を返すこと" do
        expect(response).to have_http_status "200"
      end
    end

    context "ユーザーがログインしていない場合" do
      before do
        get posts_path
      end

      it "ステータスが302を返すこと" do
        expect(response).to have_http_status "302"
      end

      it "sign_inページへリダイレクトされること" do
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  # =========================
  # new
  # =========================
  describe "#new" do
    context "ユーザーがログインしている場合" do
      before do
        sign_in user
        get new_post_path
      end

      it "ステータスが200を返すこと" do
        expect(response).to have_http_status "200"
      end
    end

    context "ユーザーがログインしていない場合" do
      before do
        get new_post_path
      end

      it "ステータスが302を返すこと" do
        expect(response).to have_http_status "302"
      end

      it "sign_inページへリダイレクトされること" do
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  # =========================
  # show
  # =========================
  describe "#show" do
    context "ユーザーがログインしている場合" do
      before do
        sign_in user
      end

      context "投稿が家族のものだと" do
        let(:family_post_for_show) { FactoryBot.create(:post, user: family_user) }

        it "ステータスが200を返すこと" do
          get post_path(family_post_for_show)
          expect(response).to have_http_status "200"
        end
      end

      context "投稿が他人のものだと" do
        it "ステータスが302を返し、トップにリダイレクトされること" do
          get post_path(others_post)
          expect(response).to have_http_status "302"
          expect(response).to redirect_to root_path
          expect(flash[:alert]).to be_present
        end
      end
    end

    context "ユーザーがログインしていない場合" do
      let(:post_record) { FactoryBot.create(:post, user: user) }

      before do
        get post_path(post_record)
      end

      it "ステータスが302を返すこと" do
        expect(response).to have_http_status "302"
      end

      it "sign_inページへリダイレクトされること" do
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  # =========================
  # edit
  # =========================
  describe "#edit" do
    context "ユーザーがログインしている場合" do
      context "自分の投稿の場合" do
        before do
          sign_in user
          get edit_post_path(own_post)
        end

        it "ステータスが200を返すこと" do
          expect(response).to have_http_status "200"
        end
      end

      context "same family + admin の場合（family_admin が family メンバー投稿を編集）" do
        before do
          sign_in user   # user は family_admin: true
          get edit_post_path(family_post)
        end

        it "ステータスが200を返すこと" do
          expect(response).to have_http_status "200"
        end
      end

      context "same family + non-admin の場合（一般メンバーが family_admin の投稿を編集しようとする）" do
        before do
          sign_in family_user
          get edit_post_path(own_post)
        end

        it "ステータスが302を返し、トップにリダイレクトされること" do
          expect(response).to have_http_status "302"
          expect(response).to redirect_to post_path(own_post)
        end
      end

      context "別 family のユーザーの投稿の場合" do
        before do
          sign_in other_user
          get edit_post_path(own_post)
        end

        it "ステータスが302を返し、トップにリダイレクトされること" do
          expect(response).to have_http_status "302"
          expect(response).to redirect_to post_path(own_post)
        end
      end
    end

    context "ユーザーがログインしていない場合" do
      before do
        get edit_post_path(own_post)
      end

      it "ステータスが302を返すこと" do
        expect(response).to have_http_status "302"
      end

      it "sign_inページへリダイレクトされること" do
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  # =========================
  # create
  # =========================
  describe "POST /posts" do
    context "ユーザーがログインしている場合" do
      before do
        sign_in user
      end

      it "保存できたら詳細ページにリダイレクトすること" do
        post_params = FactoryBot.attributes_for(:post)

        expect {
          post posts_path, params: { post: post_params }
        }.to change(Post, :count).by(1)

        created_post = Post.last
        expect(flash[:notice]).to include "投稿を作成しました。"
        expect(response).to have_http_status "302"
        expect(response).to redirect_to post_path(created_post)
      end

      it "保存できなかったらステータス422を返すこと" do
        invalid_params = FactoryBot.attributes_for(:post, body: "")

        expect {
          post posts_path, params: { post: invalid_params }
        }.not_to change(Post, :count)

        expect(response).to have_http_status "422"
      end
    end

    context "ユーザーがログインしていない場合" do
      it "Postは作成されず、sign_inページへリダイレクトされること" do
        post_params = FactoryBot.attributes_for(:post)

        expect {
          post posts_path, params: { post: post_params }
        }.not_to change(Post, :count)

        expect(response).to have_http_status "302"
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  # =========================
  # update
  # =========================
  describe "PATCH /posts/:id" do
    let(:valid_params)   { { post: { body: "更新後の本文です" } } }
    let(:invalid_params) { { post: { body: "" } } }

    context "ユーザーがログインしている場合" do
      context "自分の投稿の場合" do
        before { sign_in user }

        it "有効な値なら更新され、詳細画面にリダイレクトされること" do
          patch post_path(own_post), params: valid_params

          expect(response).to have_http_status "302"
          expect(response).to redirect_to post_path(own_post)

          own_post.reload
          expect(own_post.body).to eq "更新後の本文です"
        end

        it "無効な値なら422が返り、更新されないこと" do
          original_body = own_post.body

          patch post_path(own_post), params: invalid_params

          expect(response).to have_http_status "422"
          own_post.reload
          expect(own_post.body).to eq original_body
        end
      end

      context "same family + admin の場合（family_admin が family メンバー投稿を更新）" do
        before { sign_in user }

        it "有効な値なら更新できること" do
          patch post_path(family_post), params: valid_params

          expect(response).to have_http_status "302"
          expect(response).to redirect_to post_path(family_post)

          family_post.reload
          expect(family_post.body).to eq "更新後の本文です"
        end
      end

      context "same family + non-admin の場合（一般メンバーが family_admin の投稿を更新しようとする）" do
        before { sign_in family_user }

        it "302を返し、トップにリダイレクトされ、更新されないこと" do
          original_body = own_post.body

          patch post_path(own_post), params: valid_params

          expect(response).to have_http_status "302"
          expect(response).to redirect_to post_path(own_post)

          own_post.reload
          expect(own_post.body).to eq original_body
        end
      end

      context "別 family のユーザーの投稿の場合" do
        before { sign_in other_user }

        it "302を返し、トップにリダイレクトされ、更新されないこと" do
          original_body = own_post.body

          patch post_path(own_post), params: valid_params

          expect(response).to have_http_status "302"
          expect(response).to redirect_to post_path(own_post)

          own_post.reload
          expect(own_post.body).to eq original_body
        end
      end
    end

    context "ユーザーがログインしていない場合" do
      it "302を返し、ログイン画面にリダイレクトされること" do
        patch post_path(own_post), params: valid_params
        expect(response).to have_http_status "302"
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  # =========================
  # destroy
  # =========================
  describe "DELETE /posts/:id" do
    context "ユーザーがログインしている場合" do
      context "自分の投稿の場合" do
        before { sign_in user }

        it "投稿を削除できること" do
          expect {
            delete post_path(own_post)
          }.to change(Post, :count).by(-1)

          expect(response).to have_http_status "302"
          expect(response).to redirect_to posts_path
        end
      end

      context "same family + admin の場合（family_admin が family メンバー投稿を削除）" do
        before { sign_in user }

        it "投稿を削除できること" do
          expect {
            delete post_path(family_post)
          }.to change(Post, :count).by(-1)

          expect(response).to have_http_status "302"
          expect(response).to redirect_to posts_path
        end
      end

      context "same family + non-admin の場合（一般メンバーが family_admin の投稿を削除しようとする）" do
        before { sign_in family_user }

        it "投稿は削除されず、トップにリダイレクトされること" do
          expect {
            delete post_path(own_post)
          }.not_to change(Post, :count)

          expect(response).to have_http_status "302"
          expect(response).to redirect_to post_path(own_post)
        end
      end

      context "別 family のユーザーの投稿の場合" do
        before { sign_in other_user }

        it "投稿は削除されず、トップにリダイレクトされること" do
          expect {
            delete post_path(own_post)
          }.not_to change(Post, :count)

          expect(response).to have_http_status "302"
          expect(response).to redirect_to post_path(own_post)
        end
      end
    end

    context "ユーザーがログインしていない場合" do
      it "投稿は削除されず、ログイン画面にリダイレクトされること" do
        expect {
          delete post_path(own_post)
        }.not_to change(Post, :count)

        expect(response).to have_http_status "302"
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
