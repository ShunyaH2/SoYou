class FixUsersFamilyIdIndexes < ActiveRecord::Migration[6.1]
  def up
    # 誤って作られた “family_id のユニーク” を落とす（存在する時だけ）
    if index_exists?(:users, :family_id, name: "index_users_on_family_id_unique_family_admin")
      remove_index :users, name: "index_users_on_family_id_unique_family_admin"
    end

    # 通常の index は「無ければ作る」（すでにあれば何もしない）
    unless index_exists?(:users, :family_id, name: "index_users_on_family_id")
      add_index :users, :family_id
    end
  end

  def down
    # down は安全第一で（存在するなら消す、無ければ何もしない）
    if index_exists?(:users, :family_id, name: "index_users_on_family_id")
      remove_index :users, name: "index_users_on_family_id"
    end

    # unique を復元するのは危険なので通常はやらない
    # 必要なら、ここにも index_exists? を入れて慎重に書く
  end
end