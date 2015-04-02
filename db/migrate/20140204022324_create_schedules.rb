class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.belongs_to :organization, null: false	
      t.integer :day, null: false, limit: 1
      t.boolean :is_holiday
      t.string :first_time, limit: 5
      t.string :second_time, limit: 5
    end
  end
end
