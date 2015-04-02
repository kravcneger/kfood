module Active
	extend ActiveSupport::Concern
	included do	
		after_validation :set_active_for_children
		
		def set_active_for_children
			unless active
				self.children.update_all({active: false})
			end 
			if self.parent.present? and self.parent.active == false
				self.active = false
			end
		end
	end
end