class OrderObserver < ActiveRecord::Observer
	def after_create(record)
		org = record.organization
		us = []
		us.push(@organization.push_key1) if @organization.push_key1.present?
		us.push(@organization.push_key2) if @organization.push_key2.present?
		us.each do |u|
			Pushover.notification(message: "Заказ от #{number_with_mask}", title: 'Новый заказ', user: u)
		end
	end
end
