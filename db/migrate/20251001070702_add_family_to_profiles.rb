class AddFamilyToProfiles < ActiveRecord::Migration[6.1]
  def change
    # profiles に family_id を追加（integer + index + 外部キー制約）
    add_reference :profiles, :family, foreign_key: true
  end
end
