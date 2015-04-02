module CategoriesHelper
	def self.list_options_tree(tree,indent=3)
		result = []
		tree.each_value do |item|
			result.push([item[:item].name,item[:item].id])
			item[:children].each do |child|
				result.push([('.'*indent) + child.name,child.id])
			end
		end
		result
	end
end
