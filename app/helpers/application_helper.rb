module ApplicationHelper
  def can_edit_post?(post)
    return false unless current_user
    (post.user_id == current_user.id) ||
      (
        current_user.family_admin? &&
        current_user.family_id.present? &&
        post.user&.family_id.present? &&
        current_user.family_id == post.user.family_id
      )
  end

  def can_delete_post?(post)
    can_edit_post?(post) 
  end

  def can_manage_comment?(comment)
    return false unless current_user
    is_comment_author = (comment.user_id == current_user.id)
    is_post_owner     = (comment.post.user_id == current_user.id)
    is_family_admin_same_family =
      current_user.family_admin? &&
      current_user.family_id.present? &&
      comment.post.user&.family_id == current_user.family_id

    is_comment_author || is_post_owner || is_family_admin_same_family
  end
end
