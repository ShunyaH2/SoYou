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
end
