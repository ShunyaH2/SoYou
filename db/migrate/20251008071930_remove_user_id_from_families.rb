class RemoveUserIdFromFamilies < ActiveRecord::Migration[6.1]
  def change
    remove_reference :families, :user, foreign_key: true
  end
end
