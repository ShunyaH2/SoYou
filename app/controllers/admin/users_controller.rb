class Admin::UsersController < Admin::ApplicationController
  def index
    @users = User
              .all
              .includes(:family)
              .order(created_at: :desc)
  end

  def show
    @user = User.find(params[:id])
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to admin_users_path, notice: "ユーザーを削除しました"
  end
end