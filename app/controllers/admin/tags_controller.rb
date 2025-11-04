class Admin::TagsController < Admin::ApplicationController
  before_action :set_tag, only: %i[edit update destroy]

  def index
    @q = Tag.ransack(params[:q])
    @tags = @q.result
              .order(id: :asc)
              .page(params[:page]).per(20)
  end

  def new
    @tag = Tag.new
  end

  def create
    @tag = Tag.new(tag_params)
    if @tag.save
      redirect_to admin_tags_path, notice: "タグを作成しました"
    else
      flash.now[:alert] = "作成に失敗しました"
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @tag.update(tag_params)
      redirect_to admin_tags_path, notice: "タグを更新しました"
    else
      flash.now[:alert] = "更新に失敗しました"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @tag.update!(active: false)

    redirect_to admin_tags_path, notice: "タグを削除（無効化）しました"
  end

  def restore
    @tag = Tag.find(params[:id])
    @tag.update!(active: true)
    redirect_to admin_tags_path, notice: "タグを有効に戻しました"
  end

  private
  def set_tag
    @tag = Tag.find(params[:id])
  end

  def tag_params
    params.require(:tag).permit(:name, :active)
  end
end