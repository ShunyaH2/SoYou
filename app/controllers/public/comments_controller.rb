class Public::CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post
  before_action :set_comment, only: %i[edit update destroy]
  before_action :ensure_comment_owner!, only: %i[edit update destroy]

  def create
    @comment = @post.comments.build(comment_params.merge(user: current_user))

    if @comment.save
      redirect_to post_path(@post, anchor: "comments"), notice: "コメントを投稿しました。"
    else
      @comments = @post.comments.includes(:user).order(created_at: :asc)
      flash.now[:alert] = "コメントを投稿できませんでした。"
      render "public/posts/show", status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @comment.update(comment_params)
      redirect_to post_path(@post, anchor: "comments"), notice: "コメントを更新しました。"
    else
      flash.now[:alert] = "コメントを更新できませんでした。"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @comment.destroy
    redirect_to post_path(@post, anchor: "comments"), notice: "コメントを削除しました。"
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = @post.comments.find(params[:id])
  end

  def ensure_comment_owner!
    return if @comment.user_id == current_user.id

    redirect_to post_path(@post, anchor: "comments"),
                alert: "自分のコメントのみ編集・削除できます。"
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end