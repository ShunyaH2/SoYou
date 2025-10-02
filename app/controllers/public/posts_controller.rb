class Public::PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: %i[show edit update destroy]
  before_action :authorize_owner!, only: %i[edit update destroy]

  def index
    @posts = current_user.posts
      .order(occurred_on: :desc)
      .includes(:profiles)
  end

  def show
  end

  def new
    @post = current_user.posts.new
  end

  def create
    @post = current_user.posts.new(post_params)
    if @post.save
      redirect_to @post, notice: "投稿を作成しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update 
    # 全外しでクリアできるよう、パラメータがない場合はから配列を入れる（保険）
    params[:post][:profile_ids] ||= [] if params[:post]
    if @post.update(post_params)
      redirect_to @post, notice: "投稿を更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_path, notice: "投稿を削除しました。"
  end

  private

  def set_post
    @post = Post.find(params[:id]) # 自分の投稿だけ
  end

  def authorize_owner!
    redirect_to @post, alert: "権限がありません。" unless @post.user_id == current_user.id
  end

  def post_params
    params.require(:post).permit(:body, :occurred_on, profile_ids: [])
  end
end
