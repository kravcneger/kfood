class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.belongs_to :organization, null: false 
      t.belongs_to :category, null: false 
      t.belongs_to :addition
      t.string :name, null: false
      t.text :description, null: true      
      t.integer :weight, null: true, unsigned: true
      t.integer :calories, null: true, unsigned: true
      t.integer :price, null: false, default: 0, unsigned: true
      t.integer :active, limit: 1, default: 0
      t.column :locked_to, 'timestamp without time zone' 
      t.timestamps
    end
  end
end
