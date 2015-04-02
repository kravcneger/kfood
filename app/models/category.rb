class Category < ActiveRecord::Base
	include OrganizationRelative
	include Active
	include Tree

	validates :name, presence: true, length: { minimum: 3, maximum: 128 }  
	validates :category_id, numericality: { only_integer: true , less_than: Kfood::Application.config.max_integer }, :allow_nil => true
	validate :category_id, :move
	
	after_validation :set_ordering

	has_many :products, ->(cat) { self_organization(cat).published_products }
	has_many :products_all, ->(cat) { self_organization(cat) }, class_name: :Product, dependent: :destroy

	has_many :children, class_name: "Category", foreign_key: "category_id", dependent: :destroy
	belongs_to :parent, class_name: "Category", foreign_key: "category_id"

	scope :orders, -> { order('category_id asc, ordering asc') }

	def after_category=(cat)
		if cat.is_a?(Category) && cat.respond_to?(:id) 
			@after_category = cat.id
		else 
			@after_category = cat.to_i
		end
	end

	def after_category
		@after_category
	end

	private 

	def set_ordering
		cats = self.get_brothers.to_a

		if cats.any?
			# если категория вставляется в начало списка
			if after_category == -1
				self.ordering = 0	
				cats.insert(0,[])	
			else
				cats.each_with_index do |cat,i|
					if cat.id == after_category
						self.ordering = i + 1	
						cats.insert(i + 1,[])	
						break	
					end
				end
			end

			if ordering.present?
				if ordering != ordering_was
					cats.each_with_index do |cat,i|
						cat.update_attribute(:ordering, i) if self.ordering != i
					end
				end
			else
				self.ordering = cats[-1].ordering.to_i + 1
			end		
		else
			self.ordering = 0  
		end
	end

end
