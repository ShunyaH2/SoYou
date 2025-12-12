class FixUsersFamilyIdIndexes < ActiveRecord::Migration[6.1]
  def up
    # まず “family_id のユニーク” を落とす
    remove_index :users, name: "index_users_on_family_id_unique_family_admin" rescue nil
    remove_index :users, name: "index_users_on_family_id" rescue nil

    # そして通常のindexとして作り直す（非ユニーク）
    add_index :users, :family_id
  end

  def down
    remove_index :users, :family_id rescue nil

    # 元に戻す必要があるならここに復元を書く（本来は復元しない想定）
    # add_index :users, :family_id, unique: true, name: "index_users_on_family_id_unique_family_admin"
  end
end