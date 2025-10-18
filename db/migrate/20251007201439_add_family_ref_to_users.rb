class AddFamilyRefToUsers < ActiveRecord::Migration[6.1]
  def up
    # users.family_id が無ければ追加（インデックス＆FKも補完）
    unless column_exists?(:users, :family_id)
      add_reference :users, :family, foreign_key: true, index: true
    end
    unless index_exists?(:users, :family_id)
      add_index :users, :family_id
    end
    unless foreign_key_exists?(:users, :families)
      add_foreign_key :users, :families
    end

    # 既存ユーザーの family_id を families(user_id) からバックフィル
    say_with_time "Backfilling users.family_id from families.user_id" do
      execute <<~SQL
        UPDATE users
        INNER JOIN families ON families.user_id = users.id
        SET users.family_id = families.id
        WHERE users.family_id IS NULL
      SQL
    end
  end

  def down
    # 元に戻す（安全のため存在確認）
    remove_foreign_key :users, :families if foreign_key_exists?(:users, :families)
    remove_index :users, :family_id         if index_exists?(:users, :family_id)
    remove_reference :users, :family, foreign_key: true if column_exists?(:users, :family_id)
  end
end

