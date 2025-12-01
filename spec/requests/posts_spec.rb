require 'rails_helper'

RSpec.describe "Posts", type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:other_user) { FactoryBot.create(:user) }
  let!(:own_post) { FactoryBot.create(:post, user: user) }
  let!(:others_posts)  {FactoryBot.create(:post, user: other_user) }
  let(:family_user) { FactoryBot.create(:user, family: user.family ) }
  
  # TagGeneratpr が本物のAPIをたたかないようにモックする
  before do
    dummy = instance_double(TagGenerator, assign_tags!: true)
    allow(TagGenerator).to receive(:new).and_return(dummy)
  end

  # index
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

      it "sing_inページへリダイレクトされること" do
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  # new
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

      it "ステータスが302を返すこと"
       expect(response).to have_http_status "302"
      end

      it "sign_inページへリダイレクトされること" do
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  # show
  describe "#show" do
    context "ユーザーがログインしている場合" do
      before do
        sign_in user
      end

      context "投稿が家族のものだと" do
        let(:family_post) { FactoryBot.create(:post, user: family_user) }

        it "ステータスが200を返すこと" do
          get post_path(family_post)
          expect(response).to have_http_status "200"
        end
      end

      context "投稿が他人のものだと" do 
        it "ステータスが302を返し、トップにリダイレクトされること" do
          get post_path(other_post)
          expect(response).to have_http_status "302"
          expect(response).to redirect_to root_path
          expect(flash[:alert]).to be_present
        end
      end
    end

    context "ユーザーがログインしていない場合" do
      let(:post) { FactoryBot.create(:post, user: user) }
      
      before do
        get post_path(post)
      end

      it "ステータスが302を返すこと" do
        expect(response).to have_http_status "302"
      end

      it "sing_inページへリダイレクトされること" do
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  # edit
  describe "#edit" do
    context "ユーザーがログインしている場合" do
      before do
       sign_in user
      end

      context "自分の投稿の場合" do
        it "ステータスが200を返すこと" do
          get edit_post_path(own_post)
          expect(response).to have_http_status "200"
        end
      end

      context "他人の投稿の場合" do
        it "ステータスが302を返し、トップにリダイレクトされること" do
          get edit_post_path(others_post)
          expect(response).to have_http_status "302"
          expect(response).to redirect_to root_path
          expect(flash[:alert]).to be_present
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

  #create
  describe "POST /posts" do
    context "ユーザーがログインしている場合" do
      before do
        sign_in user
      end
    
      it "保存できたらIndexにRedirectすること" do
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
        # 空の本文など、無効なパラメータを返す
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
end