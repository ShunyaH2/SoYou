class Public::CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post
  before_action :set_comment, only: :destroy
  before_action :authenticate_owner!, only: :destroy

  def create
    @comment = @post.comments.build(comment_params.merge(user: current_user))
    if @comment.save
      redirect_to post_path(@post, anchor: "comments"), notice: "コメントを投稿しました。"
    else
      # 投稿詳細でエラーも表示したいので、同じテンプレで返す
      @comments = @post.comments.includes(:user).order(created_at: :asc)
      flash.now[:alert] = "コメントを投稿できませんでした。"
      render "public/posts/show", status: :unprocessable_entity
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

  def authorize_owner!
    redirect_to post_path(@post), alert: "削除権限がありません" unless @comment.user_id == current_user.id
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end