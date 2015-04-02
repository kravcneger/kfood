class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.belongs_to :organization, null: false 
      t.belongs_to :category, default: 0
      t.boolean :active
      t.string :name
      t.integer :ordering, null: false, unsigned: true
    end
  end
end
