class Public::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[show edit update withdraw promote_to_family_admin demote_from_family_admin]
  before_action :ensure_same_family_or_self!, only: %i[show]
  before_action :ensure_family_admin!, only: %i[promote_to_family_admin demote_from_family_admin]
  before_action :ensure_same_family!,  only: %i[promote_to_family_admin demote_from_family_admin]
  before_action :ensure_self!, only: %i[edit update withdraw]
  
  def show
    @posts = @user.posts.includes(:profiles).order(created_at: :desc)
    @family_members = @user.family ? @user.family.users.order(:id) : []
  end

  def edit
    @user.build_profile(family: @user.family) unless @user.profile
    @user.profile.birthday ||= 30.years.ago.to_date
  end

  def update
    @user.build_profile(family: @user.family) unless @user.profile
    @user.profile.family ||= @user.family if @user.profile
    
    if @user.update(user_params)
      flash[:notice] = "プロフィールを更新しました"
      redirect_to @user
    else
      Rails.logger.debug "USER UPDATE ERRORS: #{@user.errors.full_messages.inspect}"
      flash.now[:alert] = @user.errors.full_messages.join(' / ')
      render :edit, status: :unprocessable_entity
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

  def promote_to_family_admin
    if @user.family_admin?
      redirect_back fallback_location: user_path(@user), alert: "すでに家族管理者です。"
      return
    end

    User.transaction do
      User.where(family_id: @user.family_id, family_admin: true).update_all(family_admin: false)
      @user.update!(family_admin: true)
    end

    redirect_back fallback_location: user_path(@user), notice: "家族管理者#{@user.name || @user.email}に移譲しました。"
  rescue => e
    redirect_back fallback_location: user_path(@user), alert: "移譲に失敗しました: #{e.message}"
  end

  def demote_from_family_admin
    # 最後の家族管理者は降格不可
    if @user.family_admin? && User.where(family_id: @user.family_id, family_admin: true).count == 1
      redirect_back fallback_location: user_path(@user), alert: "最後の家族管理者は降格できません。"
      return
    end

    @user.update!(family_admin: false)
    redirect_back fallback_location: user_path(@user), notice: "家族管理者を解除しました。"
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def ensure_same_family_or_self!
    # 自分自身ならOK
    return if @user == current_user
  
    # family_id が両方あって、かつ同じならOK
    if @user.family_id.present? && current_user.family_id.present? &&
       @user.family_id == current_user.family_id
      return
    end
  
    # それ以外はNG
    redirect_to(root_path, alert: "同じ家族のユーザーのみ閲覧できます。")
  end
  

  def ensure_self!
      redirect_to(root_path, alert: "権限がありません") unless @user && @user == current_user
  end

  def ensure_same_family!
    unless @user.family_id.present? && current_user.family_id.present? && @user.family_id == current_user.family_id
      redirect_back fallback_location: user_path(@user), alert: "同じファミリーのユーザーのみ操作できます。"
    end
  end

  def ensure_family_admin!
    unless current_user.family_admin?
      redirect_back fallback_location: user_path(@user), alert: "家族管理者のみ実行できます。"
    end
  end

  def user_params
    params.require(:user)
          .permit(:email, profile_attributes: [:id, :name, :birthday])
  end  
end
