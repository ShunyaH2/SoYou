class ChangeProfilesUserIdNullable < ActiveRecord::Migration[6.1]
  def change
    # profiles.user_idをnull許可に変更
    change_column_null :profiles, :user_id, true
  end
end
