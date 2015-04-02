module Tree
	extend ActiveSupport::Concern

	included do
		def get_tree(data)
			result = {}
			data.each do |item|
				entity_name = item.class.name.downcase
				method_name = entity_name + '_id'

				if item.is_sub?
					if result[item.send(method_name)].present?
						result[item.send(method_name)][:children].push(item)
					end
				else
					result[item.id] = { item: item, children: []}   
				end
			end
			result
		end

		def is_sub?
			self.send(get_method).present? and self.send(get_method) != 0
		end	

		def parent?
      !is_sub?
		end	

		def get_brothers
			q = " organization_id = ? AND category_id = ? AND id <> ? "
			self.class.where(q, self.organization_id, self.send(get_method) || 0, self.id || 0).order(self.respond_to?(:ordering) ? 'ordering' : 'name')
		end

		private 

		def get_entity
			self.class.name.downcase
		end

		def get_method
			(get_entity + '_id').to_sym
		end

		def move
			if self.send(get_method).present? && self.send(get_method) != 0
		  	if self.send(get_method) == self.id || parent.blank? || parent.is_sub? || parent.organization_id != self.organization_id
		  		self.errors[get_method] << 'Incorrect category'
		  	end

		  	if self.children.present?
		  		self.errors[get_method] << 'Parent have sub elements'
		  	end		
		  end 
		end
	end
end