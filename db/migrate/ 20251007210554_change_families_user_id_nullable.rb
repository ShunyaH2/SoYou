class ChangeFamiliesUserIdNullable < ActiveRecord::Migration[6.1]
  def change
    change_column_null :families, :user_id, true
  end
end
