module OrganizationsHelper
	# проверяет доступены ли элементы управления на странице
	def available_control?
    organization_signed_in? and (current_organization == @organization)
	end
end
