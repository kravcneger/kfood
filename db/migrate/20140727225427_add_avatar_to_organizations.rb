class AddAvatarToOrganizations < ActiveRecord::Migration
	def self.up
		add_attachment :organizations, :avatar
	end

	def self.down
		remove_attachment :organizations, :avatar
	end
end
