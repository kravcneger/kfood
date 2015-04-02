class Basket
	attr_accessor :products, :price, :delivery

	def initialize
		clear
	end

	def clear
		@products = {}
    @price = 0
    @delivery = 0
	end
end