class CreateFamilies < ActiveRecord::Migration[6.1]
  def change
    create_table :families do |t|
      t.references :user, null: false, foreign_key: true
      t.string :code
      t.string :name

      t.timestamps
    end
  end
end
