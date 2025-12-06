require 'rails_helper'

RSpec.describe "Users", type: :request do
  let(:user)        { FactoryBot.create(:user) }
  let(:other_user)  { FactoryBot.create(:user) }
  let(:family_user) { FactoryBot.create(:user, family: user.family) }

  # --- GET /users/:id (show) ---
  describe "#show" do
    context "ログインしている場合" do
      before { sign_in user }

      context "自分のページの場合" do
        it "200を返すこと" do
          get user_path(user)
          expect(response).to have_http_status "200"
        end
      end

      context "同じ familyのユーザーの場合" do
        it "200を返すこと" do
          get user_path(family_user)
          expect(response).to have_http_status "200"
        end
      end

      context "別の family のユーザーの場合" do
        it "302を返し、トップにリダイレクトされること" do
          get user_path(other_user)
          expect(response).to have_http_status "302"
          expect(response).to redirect_to root_path
          expect(flash[:alert]).to be_present
        end
      end
    end

    context "ログインしていない場合" do
      it "302を返し、ログイン画面にリダイレクトされること" do
        get user_path(user)
        expect(response).to have_http_status "302"
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  # --- GET /users/:id/edit ---
  describe "#edit" do
    context "ログインしている場合" do
      before { sign_in user }

      context "自分のページの場合" do
        it "200を返すこと" do
          get edit_user_path(user)
          expect(response).to have_http_status "200"
        end
      end

      context "他人のページの場合" do
        it "302を返し、トップにリダイレクトされること" do
          get edit_user_path(other_user)
          expect(response).to have_http_status "302"
          expect(response).to redirect_to root_path
          expect(flash[:alert]).to be_present
        end
      end
    end

    context "ログインしていない場合" do
      it "302を返し、ログイン画面にリダイレクトされること" do
        get edit_user_path(user)
        expect(response).to have_http_status "302"
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  # --- PATCH /users/:id ---
  describe "PATCH /users/:id" do
    let(:valid_params) do
      {
        user: {
          email: "new@example.com",
          profile_attributes: {
            name: "テストユーザー",
            birthday: "2000-01-01"
          }
        }
      }
    end
    let(:invalid_params) { { user: { email: "" } } }

    context "ログインしている場合" do
      before { sign_in user }

      context "自分の情報を更新する場合" do
        it "有効な値なら更新され、マイページにリダイレクトされること" do
          patch user_path(user), params: valid_params

          expect(response).to have_http_status "302"
          expect(response).to redirect_to user_path(user)
          expect(flash[:notice]).to include "プロフィールを更新しました"

          user.reload
          expect(user.email).to eq "new@example.com"
        end

        it "無効な値なら422が返り、更新されないこと" do
          original_email = user.email

          patch user_path(user), params: invalid_params

          expect(response).to have_http_status "422"
          user.reload
          expect(user.email).to eq original_email
        end
      end

      context "他人の情報を更新しようとした場合" do
        it "302を返し、トップにリダイレクトされること" do
          patch user_path(other_user), params: valid_params
          expect(response).to have_http_status "302"
          expect(response).to redirect_to root_path
          expect(flash[:alert]).to be_present
        end
      end
    end

    context "ログインしていない場合" do
      it "302を返し、ログイン画面にリダイレクトされること" do
        patch user_path(user), params: valid_params
        expect(response).to have_http_status "302"
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  # --- PATCH /users/:id/withdraw ---
  describe "PATCH /users/:id/withdraw" do
    context "ログインしている場合" do
      before { sign_in user }

      context "自分自身を退会させる場合" do
        it "status が withdrawn になり、サインアップ画面にリダイレクトされること" do
          patch withdraw_user_path(user)

          expect(response).to have_http_status "302"
          expect(response).to redirect_to new_user_registration_path
          expect(flash[:notice]).to include "退会処理が完了しました"

          user.reload
          expect(user.status).to eq "withdrawn"
        end
      end

      context "他人を退会させようとした場合" do
        it "302を返し、トップにリダイレクトされること" do
          patch withdraw_user_path(other_user)
          expect(response).to have_http_status "302"
          expect(response).to redirect_to root_path
          expect(flash[:alert]).to be_present
        end
      end
    end

    context "ログインしていない場合" do
      it "302を返し、ログイン画面にリダイレクトされること" do
        patch withdraw_user_path(user)
        expect(response).to have_http_status "302"
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end