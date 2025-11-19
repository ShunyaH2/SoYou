class Admin::UsersController < Admin::ApplicationController
  before_action :authenticate_admin!
  before_action :set_user, only: %i[show destroy promote_family_admin demote_family_admin]
  
  def index
    @q = User.includes(:family, :profile).ransack(params[:q])
    @users = @q.result(distinct: true)
              .order(:id)
              .page(params[:page])
              .per(20)
  end

  def show
  end

  def destroy
    @user.update(status: :withdrawn)
    redirect_to admin_users_path, notice: "退会処理が完了しました"
  end

  def promote_family_admin
    User.transaction do
      # 同じ家族の現在の家族管理者をいったん全員解除
      User.where(family_id: @user.family_id, family_admin: true)
          .where.not(id: @user.id)
          .update_all(family_admin: false)
  
      # 対象ユーザーを家族管理者に
      @user.update!(family_admin: true)
    end
  
    redirect_to admin_user_path(@user), notice: "家族管理者に設定しました。"
  rescue => e
    redirect_to admin_user_path(@user), alert: "設定に失敗しました: #{e.message}"
  end

  def demote_family_admin
    if @user.respond_to?(:last_family_admin?) && @user.last_family_admin?
      redirect_to admin_user_path(@user), alert: "家族管理者を不在にすることはできません。"
    else
      @user.update!(family_admin: false)
      redirect_to admin_user_path(@user), notice: "家族管理者を解除しました。"
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end