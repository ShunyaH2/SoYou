class Public::ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_family #ログインユーザーのfamilyを取得
  before_action :set_profile, only: [:edit, :update, :destroy] # id付きの時だけプロフィールを取得

  def index
    @profiles = @family.profiles.order(:created_at)
  end

  def new
    @profile = @family.profiles.new
  end

  def create
    @profile = @family.profiles.new(profile_params)
    if @profile.save
      redirect_to family_profiles_path, notice: "プロフィールを追加しました"
    else
      flash.now[:alert] = "追加に失敗しました"
      render :new
    end
  end

  def edit
  end

  def update
    @profile = @family.profiles.find(params[:id])
    if @profile.update(profile_params)
      redirect_to family_profiles_path, notice: "プロフィールを更新しました"
    else
      flash.now[:alert] = "更新に失敗しました"
      render :edit
    end
  end

  def destroy
    @profile = @family.profiles.find(params[:id])
    @profile.destroy
    redirect_to family_profiles_path, notice: "プロフィールを削除しました"
  end

  private

  def set_family
    @family = current_user.family
  end

  def set_profile
    @profile = @family.profiles.find(params[:id])
  end

  def profile_params
    params.require(:profile).permit(:name, :birthday, :role)
  end
end

