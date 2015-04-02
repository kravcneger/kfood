class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.belongs_to :organization, null: false 
      t.string :name, null: false
      t.string :contact_phone, null: false, limit: 11
      t.string :street, null: false
      t.string :house, null: false
      t.column :addition_info, 'json'
      t.column :time_order, 'timestamp without time zone'  
      t.text :comment
      t.column :body, 'json NOT NULL'
      t.integer :price, null: false
      t.integer :delivery, null: false
      t.boolean :viewed, default: false
      t.boolean :notified, default: false
      t.integer :status, default: 0, limit: 1
      t.cidr :ip
      t.timestamps
    end
  end
end
