class AddFamilyAdminToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :family_admin, :boolean

    add_index :users, :family_id,
              unique: true,
              where: "family_admin = 1",
              name: "index_users_on_family_id_unique_family_admin"
  end
end
