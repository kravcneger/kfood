class CreateAdditions < ActiveRecord::Migration
  def change
    create_table :additions do |t|
      t.belongs_to :organization, null: false
      t.belongs_to :addition, default: 0
      t.string :name, null: false
      t.integer :price, null: true, unsigned: true
      t.boolean :active
    end
  end
end
