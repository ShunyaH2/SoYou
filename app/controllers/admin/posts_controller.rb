class Admin::PostsController < Admin::ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  def index
    @q = params[:q]
    @posts = Post.search(@q)
            .includes(:user)
            .distinct
            .order(created_at: :desc)
            .page(params[:page])
            .per(10)
  end

  def show
  end

  def edit
  end

  def update
    if @post.update(post_params)
      redirect_to admin_post_path(@post), notice: "投稿を更新しました。"
    else
      flash.now[:alert] = "更新に失敗しました。"
      render :edit, status: :unprocessable_entity
    end
  end


  def destroy
    post = Post.find(params[:id])
    post.destroy
    redirect_to admin_posts_path, notice: "投稿を削除しました。"
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  # 管理者は本文のみ編集できる想定。必要に応じて許可カラムを増やす
  def post_params
    params.require(:post).permit(:body)
  end
end
