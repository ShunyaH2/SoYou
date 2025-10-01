class Public::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :ensure_self!, only: [:edit, :upadate, :withdraw]
  
  def show
    @posts = @user.posts.order(created_at: :desc)
  end

  def edit
    @user.build_profile unless @user.profile
  end

def user_params
  params.require(:user)
        .permit(:email, profile_attributes: [:id, :name, :birthday])
end

  def upadate
    if @user.update(user_params)
      flash[:notice] = "プロフィールを更新しました"
      redirect_to @user
    else
      flash.now[:alert] = "更新に失敗しました"
      render :edit
    end
  end

  # 退会（論理削除）
  def withdraw
    if @user.update(status: :withdrawn)
      sign_out @user
      flash[:notice] = "退会処理が完了しました"
      redirect_to new_user_registration_path
    else
      redirect_to @user, alert: "退会処理に失敗しました"
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def ensure_self!
    redirect_to(root_path, alert: "権限がありません") unless @user == current_user
  end

  def user_params
    params.require(:user).permit(:name, email)
  end
end
