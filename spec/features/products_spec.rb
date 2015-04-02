require 'spec_helper'

feature 'Products', :js => true do
	subject { page }
	let!(:org) { create(:organization) }
	let!(:cat1){ org.categories.create!(name: 'cat1', active: true) }
	let!(:cat2){ org.categories.create!(name: 'cat2', active: true) }
	let!(:product){ create(:product, organization_id: org.id, category_id: cat1.id, name: 'product1') }
	before do 
		sign_in org			
		visit view_products_path(org,cat1)
		sleep 1
	end

	it { expect(first('#menu')).to have_selector("li[data-id='#{cat1.id}'][class='active']") }

	it 'Create product' do
		# incorrect data
		first('#new_product').click
		sleep 1
		first('#save_product').click
		sleep 1
		expect(first('#myModal div.errors').text.lstrip).not_to eq('')

		find('#product_category_id').find("option[value='#{cat2.id}']").select_option
		find('#product_active').find("option[value='1']").select_option
		first('#product_name').set("product1")
		first('#product_price').set(140)
		first('#save_product').click
		sleep 2

		expect(Product.last.name).to eq('product1')
		expect(page).to have_selector('.product', count: 1)
	#	expect(first('#menu')).not_to have_selector("li[data-id='#{cat1.id}'][class='active']")
	#	expect(first('#menu')).to have_selector("li[data-id='#{cat2.id}'][class='active']")
	end

	it 'Destroy image' do
		product.avatar = File.new("#{Rails.root}/spec/fixtures/avatar.png")
		product.save
		first('.product').hover
		first('.product').first('.glyphicon-pencil').click
		sleep 2

		expect(first('#myModal')).to have_selector('img', visible: true)
		expect(first('#myModal img')['src']).to match(/#{product.avatar.url(:preview, timestamp: false)}/)

		first('#myModal .refresh_image').click
		expect(first('#myModal')).not_to have_selector('img', visible: true)

		first('#myModal .refresh_image').click
		first('#myModal .remove_image').click
		sleep 1
		page.driver.browser.switch_to.alert.accept
		sleep 2
		expect(first('#myModal')).not_to have_selector('img', visible: true)
		expect(product.reload.avatar?).to eq(false)
		expect(first('img')['src']).to match(/assets\/preview.png/)
	end

	it 'Destroy product' do
		expect do
			first('.product').hover
			first('.product').first('.glyphicon-remove').click
			page.driver.browser.switch_to.alert.accept
			sleep 2
		end.to change{org.products.count}.by(-1)
		expect(page).not_to have_selector(".product[data-id='#{product.id}']")
	end

	it 'Update product' do
		first('.product').hover
		first('.product').first('.glyphicon-pencil').click
		sleep 1

		first('#product_name').set("")
		first('#product_price').set(140)
		first('#save_product').click
		sleep 1
		expect(first('#myModal div.errors').text.lstrip).not_to eq('')

		# first('#product_name').set("new_name_product")
		fill_in 'product_name', :with => 'new_name_product'
		page.execute_script("$('#save_product').trigger('click');")
		sleep 3
		expect(page.find('.product').text).to match(/new_name_product/)

		first('.product').hover
		first('.product').first('.glyphicon-pencil').click

		sleep 2
		find('#product_category_id').find("option[value='#{cat2.id}']").select_option
		first('#save_product').click
		sleep 3
		expect(page).not_to have_selector(".product")
		expect(cat2.products_all.first).to eq(product)
	end

end