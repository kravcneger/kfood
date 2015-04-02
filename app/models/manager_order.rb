class ManagerOrder

	def initialize(organization, basket)
		raise ArgumentError unless basket.is_a?(Basket)
		raise ArgumentError unless organization.is_a?(Organization)

		@organization = organization
		@basket = basket
		@errors = []
	end
	
	def add_product(product_str, count = 1)
		raise ArgumentError if product_str.blank? or !product_str.is_a?(String)

		count = count.to_i <= 0 ? 1 : count.to_i
		begin
			segments = product_str.split('_')
			id = segments[0].to_i
			if segments.size > 1
				additions = segments[1..-1].map(&:to_i).uniq.sort				
			end
		rescue
			add_error('Error')
			return false
		end

		product = @organization.products.where(id: id).first
		if product.blank?
			add_error('Ordered product is not found')
			return false       
		end

		unless product.available_to_order?
			add_error("#{product.name} is not available")
			return false       
		end

		additionals = []
		if additions.present?
			additionals = @organization.additions.where(id: additions, active: true, addition_id: product.addition_id)
		end

		put_product(product, count, additionals)
		recalculate
		true
	end

	def add_addition_to_product(product_str,c_id)
		if @basket.products[product_str].present?
			new_product_str = product_str.to_s + '_' + c_id.to_s      
			count = @basket.products[product_str][:count]
			remove_product(product_str)
			add_product(new_product_str, count)			
		end
	end

	def remove_addition(product_str,c_id)
		if @basket.products[product_str].present?
			new_product_str = product_str.gsub(/_#{c_id.to_s}_/,'_')
			new_product_str.gsub!(/_#{c_id.to_s}$/,'')

			count = @basket.products[product_str][:count]      
			remove_product(product_str)
			add_product(new_product_str, count)			
		end
	end

	def set_number_product(product_str, count = 1)
		@basket.products.delete(product_str)
		add_product(product_str, count)
	end	

	def remove_product(product_str)
		@basket.products.delete(product_str)
		recalculate
	end	

	def clear_basket
		@basket.clear
	end

	def to_order(params={})
		@errors.clear
		params[:body] = @basket.dup
		
		if Kfood::Application.config.order_limit_count.present?
			if @organization.orders.where("ip = ? AND created_at >= ?", params[:ip], (Time.now - Kfood::Application.config.order_limit_for_time.hours ) ).count >= Kfood::Application.config.order_limit_count
				add_error("Вы превысили лимит заказов. Попробуйте совершить заказ позже.")
				return false
			end
		end

		params[:body].products.each do |key, value|
			pr_id = key.split('_')[0].to_i
			product = @organization.products.where(id: pr_id).first
			if product.blank? or !product.available_to_order?
				add_error("#{value[:name]} is not available")
				return false
			end
		end

		if @basket.price == 0 || @basket.price < @organization.min_delivery
			add_error("The sum of the order is less than minimally allowable one")
			return false
		end

		params[:body] = @basket.to_json    
		params[:price] = @basket.price
		params[:delivery] = @basket.delivery

		order = @organization.orders.new(params)
		if order.save
			@errors.clear
			@basket.clear
			@order = order
			true
		else	
			order.errors.each do |attr, msg|
				add_error("#{attr} #{msg}") if order.errors[attr].first == msg
			end
			false
		end    
	end

	def add_error(error)
		@errors.push(error)
	end

	def has_errors?
		@errors.any?
	end

	def errors
		@errors
	end

	def order
		@order ||= nil
	end

	private

	def put_product(product, count=0, additionals)
		key = "#{product.id}"
		if additionals.present?
			key = key + '_' + additionals.map(&:id).join('_')		  
		end
		@basket.products[key] ||= {}

		if product.addition_id
			@basket.products[key][:additionals] = {}
			if additionals.present?
				additionals.each do |ad|
					@basket.products[key][:additionals][ad.id] = {name: ad.name, price: ad.price}
				end
			end
		end
		@basket.products[key][:id] = product.id
		@basket.products[key][:name] = product.name
		@basket.products[key][:price] = product.price
		@basket.products[key][:count] = @basket.products[key][:count].to_i + count.to_i
	end

	def recalculate
		@basket.price = 0		
		@basket.products.each do |key, value|
			price = value[:price]
			if value[:additionals].present?
				value[:additionals].each do |k, v|
					price += v[:price] 
				end
			end
			@basket.products[key][:all_price] = price * value[:count]
			@basket.price += @basket.products[key][:all_price]      
		end

		if (@organization.free_shipping != 0 and @organization.free_shipping <= @basket.price) || @basket.price == 0
			@basket.delivery = 0
		else
			@basket.delivery = @organization.delivery
		end
	end

end