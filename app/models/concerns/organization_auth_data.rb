module OrganizationAuthData
	extend ActiveSupport::Concern
	included do
		def update(attributes)
			if attributes[:password] || attributes[:current_password] || ( attributes[:email] and attributes[:email] != self.email_was )
				update_with_password(attributes)
			else
				update_without_password(attributes)
			end
		end 
	end
end