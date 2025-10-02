class CreatePostProfiles < ActiveRecord::Migration[6.1]
  def change
    create_table :post_profiles do |t|
      t.references :post, null: false, foreign_key: true # 投稿ID
      t.references :profile, null: false, foreign_key: true # 対象プロフィールID

      t.timestamps
    end

    # 同じ投稿に同じプロフィールを二十で紐づけないための制約
    add_index :post_profiles, [:post_id, :profile_id], unique: true
  end
end
