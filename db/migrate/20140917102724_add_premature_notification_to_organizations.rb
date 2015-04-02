class AddPrematureNotificationToOrganizations < ActiveRecord::Migration
  def change
  	add_column :organizations, :premature_notification, :integer, default: 1
  end
end
