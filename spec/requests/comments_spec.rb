require 'rails_helper'

RSpec.describe "Comments", type: :request do
  let(:user)       { FactoryBot.create(:user) }
  let(:other_user) { FactoryBot.create(:user) }
  let(:post_record){ FactoryBot.create(:post, user: user) }

  # Post 保存時に TagGenerator が API を叩かないようモック
  before do
    dummy = instance_double(TagGenerator, assign_tags!: true)
    allow(TagGenerator).to receive(:new).and_return(dummy)
  end

  describe "POST /posts/:post_id/comments" do
    context "ユーザーがログインしている場合" do
      before { sign_in user }

      it "有効な内容ならコメントが作成されること" do
        comment_params = { body: "コメントテスト" }

        expect {
          post post_comments_path(post_record), params: { comment: comment_params }
        }.to change(Comment, :count).by(1)

        expect(response).to have_http_status "302"
        expect(flash[:notice]).to be_present
        # 実装に合わせて必要なら:
        # expect(response).to redirect_to post_path(post_record)
      end

      it "無効な内容（本文空）ならコメントが作成されないこと" do
        comment_params = { body: "" }

        expect {
          post post_comments_path(post_record), params: { comment: comment_params }
        }.not_to change(Comment, :count)

        # 失敗時の挙動は実装依存なので「リダイレクトしてない」くらいにとどめる
        expect(response).not_to have_http_status "302"
      end
    end

    context "ユーザーがログインしていない場合" do
      it "コメントが作成されず、ログイン画面にリダイレクトされること" do
        comment_params = { body: "ログインしていないコメント" }

        expect {
          post post_comments_path(post_record), params: { comment: comment_params }
        }.not_to change(Comment, :count)

        expect(response).to have_http_status "302"
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "DELETE /posts/:post_id/comments/:id" do
    let!(:own_comment)   { Comment.create!(user: user,       post: post_record, body: "自分のコメント") }
    let!(:other_comment) { Comment.create!(user: other_user, post: post_record, body: "他人のコメント") }

    context "ユーザーがログインしている場合" do
      before { sign_in user }

      it "自分のコメントは削除できること" do
        expect {
          delete post_comment_path(post_record, own_comment)
        }.to change(Comment, :count).by(-1)

        expect(response).to have_http_status "302"
        expect(flash[:notice]).to be_present
      end

      it "他人のコメントは削除できないこと" do
        expect {
          delete post_comment_path(post_record, other_comment)
        }.not_to change(Comment, :count)

        expect(response).to have_http_status "302"
        # 実装に合わせてトップ or 投稿詳細にリダイレクトしている想定
        expect(flash[:alert]).to be_present
      end
    end

    context "ユーザーがログインしていない場合" do
      it "コメントは削除されず、ログイン画面にリダイレクトされること" do
        expect {
          delete post_comment_path(post_record, own_comment)
        }.not_to change(Comment, :count)

        expect(response).to have_http_status "302"
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end
