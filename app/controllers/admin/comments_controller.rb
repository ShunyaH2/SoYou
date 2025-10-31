class Admin::CommentsController < Admin::ApplicationController
  def index
    @comments = Comment
                  .includes(:user, :post)
                  .order(created_at: :desc)
                  .page(params[:page])
                  .per(10)
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
    redirect_to admin_comments_path, notice: "コメントを削除しました"
  end
end