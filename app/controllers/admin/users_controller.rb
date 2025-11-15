class Admin::UsersController < Admin::ApplicationController
  def index
    @q = User.includes(:family, :profile).ransack(params[:q])
    @users = @q.result(distinct: true)
              .order(:id)
              .page(params[:page])
              .per(20)
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