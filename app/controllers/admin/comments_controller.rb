class Admin::CommentsController < Admin::ApplicationController
  def index
    @q = Comment.includes(:user, :post).ransack(params[:q])

    @comments = @q.result(distinct: true)
                  .order(created_at: :desc)
                  .page(params[:page])
                  .per(20)
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
    redirect_to admin_comments_path, notice: "コメントを削除しました"
  end
end