module ProductsHelper
	def description_product(product)		
		img = '<div class="thumbnail" style="max-height: 260px;"><div class="post-img-content">'+ image_tag(product.avatar.url(:thumb)) + '</div></div>'
		str = ''
		str += '<small>'+product.description.to_s+'</small>'
		variables = []
		variables.push(product.calories.to_s + ' ккал.')  if product.calories.present?
		variables.push(product.weight.to_s+ ' г.') if product.weight.present? 
    variables = variables.present? ? "(<b>#{variables.join(', ').to_s}</b>)" : ''
    '<div style="overflow:hidden;height:330px;max-width:260px;">' + img + str + variables + '</div>'
	end
end
