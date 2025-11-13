class Public::FamiliesController < ApplicationController
  before_action :authenticate_user!

  def show
    @family = current_user.family
    unless @family
      redirect_to edit_user_path(current_user), alert: "ファミリー未登録です。プロフィール編集から参加/作成してください。"
      return
    end

    # メンバー一覧（プロフィールを一緒に取得）
    @members = @family.users.includes(:profile).order(:id)
  end
end