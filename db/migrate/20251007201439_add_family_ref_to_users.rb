class AddFamilyRefToUsers < ActiveRecord::Migration[6.1]
  def up
    # 1) カラム追加（外部キー＆インデックス付き）
    add_reference :users, :family, foreign_key: true

    # 2）既存データのバックフィル
    #　　現状はfamilies.user_idが「オーナー＝ユーザー」を指している前提
    execute <<~SQL
      UPDATE users
      SET family_id = families.id
      FROM families
      WHERE families.user_id = users.id
    SQL
  end

  def down
    remove_reference :users, :family, foreign_key: true
  end
end

