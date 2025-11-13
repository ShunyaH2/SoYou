class Public::PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: %i(show edit update destroy)
  before_action :authorize_post_access!, only: %i(show)
  before_action :authorize_post_editor!, only: %i(edit update destroy)

  def index
    # Ransack 検索オブジェクト
    base =
      if current_user.family_id.present?
        Post.joins(:user).where(users: { family_id: current_user.family_id })
      else
        current_user.posts
      end

    @q = base.ransack(params[:q])

    @posts = @q.result(distinct: true)
              .includes(:user, :profiles, :tags)
              .order(created_at: :desc)
              .page(params[:page])
              .per(10)
    if params[:tag_id].present?
      @posts = @posts.joins(:tags).where(tags: { id: params[:tag_id] })
    end
  end

  def show
    @post = Post.find(params[:id])
    @comments = @post.comments.includes(:user).order(created_at: :asc)
  end

  def new
    @post = current_user.posts.new
  end

  def create
    @post = current_user.posts.new(post_params)
    if @post.save
      notice = "投稿を作成しました。"
      #if @post.invalid_tag_names.present?
      #  notice << "(未登録タグをスキップ: #{@post.invalid_tag_names.join('、')}) "
      #end
      redirect_to @post, notice: notice
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
      notice = "投稿を更新しました。"
      #if @post.invalid_tag_names.present?
      #  notice << "(未登録タグをスキップ: #{@post.invalid_tag_names.join('、')}) "
      #end
      redirect_to @post, notice: notice
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
    @post = Post.find(params[:id])
  end

  def authorize_post_access!
    allowed =
      (@post.user_id == current_user.id) ||
      (
        current_user.family_id.present? &&
        @post.user&.family_id.present? &&
        current_user.family_id == @post.user.family_id
      )
    redirect_to root_path, alert: "権限がありません。" unless allowed
  end

  def authorize_post_editor!
    allowed =
      (@post.user_id == current_user.id) ||
      (
        current_user.family_admin? &&
        current_user.family_id.present? &&
        @post.user&.family_id.present? &&
        current_user.family_id == @post.user.family_id
      )
    redirect_to post_path(@post), alert: "この投稿を編集・削除する権限がありません。" unless allowed
  end

  def post_params
    params.require(:post).permit(:body, :occurred_on, :tag_names, profile_ids: [], tag_ids: [])
  end
end
