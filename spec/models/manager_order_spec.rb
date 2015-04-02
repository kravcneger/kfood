require 'spec_helper'

describe ManagerOrder do  
	let(:basket){ Basket.new }
	let(:org){ create(:organization, delivery: 30, free_shipping: 60, min_delivery: 40) }
	let(:manager){ ManagerOrder.new(org, basket)  }
	let!(:cat){ create(:category, name: 'cat2', organization_id: org.id) }

	let!(:add1){ create(:addition, name: 'add1', organization_id: org.id, active: true) }
	let!(:add1_1){ create(:addition, name: 'add1_1', price: 10, addition_id: add1.id, organization_id: org.id, active: true) }
	let!(:add1_2){ create(:addition, name: 'add1_2', price: 20, addition_id: add1.id, organization_id: org.id, active: true) }
	
	let!(:pr1){ create(:product, organization_id: org.id, category_id: cat.id, active: 1, price: 12) }
	let!(:pr2){ create(:product, organization_id: org.id, locked_to: (Time.now - 1.week) , category_id: cat.id, active: 2, price: 15) }
	let!(:pr3){ create(:product, organization_id: org.id, category_id: cat.id, active: 0, price: 18) }
	let!(:pr4){ create(:product, organization_id: org.id, category_id: cat.id, active: 1, price: 20) }
	subject { manager }

	before do
		manager.clear_basket
	end

	describe "#add_product" do
		it "Product is not found" do
			expect(manager.add_product("#{pr3.id+10}", 2)).to eq(false)
			expect(manager.errors).to include('Ordered product is not found')
		end

		it "Product is not available" do
			expect(manager.add_product("#{pr3.id}", 2)).to eq(false)
			expect(manager.errors).to include("#{pr3.name} is not available")
		end

		it "Added successfully without additions" do
			expect(manager.add_product("#{pr2.id}_#{add1_1.id}", 2)).to eq(true)
			expect(basket.to_json).to eq({products: {"#{pr2.id}"=> {additionals:{}, id: pr2.id,  name: pr2.name, price: 15, count: 2, all_price: 30 }}, price: 30, delivery: 30}.to_json)
		end

		it "Added successfully with additions" do
			pr2.update(addition_id: add1.id)
			expect(manager.add_product("#{pr2.id}_#{add1_1.id}_#{add1_2.id}_#{add1.id}", 2)).to eq(true)
			expect(manager.add_product("#{pr2.id}_#{add1_1.id}")).to eq(true)
			expect(manager.add_product("#{pr2.id}_#{add1_1.id}")).to eq(true)
			expect(manager.add_product("#{pr4.id}", 1)).to eq(true)
			expect(basket.to_json).to eq( 
				{products: 
					{ 
						"#{pr2.id}_#{add1_1.id}_#{add1_2.id}"=> 
						{ 
							additionals: 
							{ 
								"#{add1_1.id}"=> {name: "add1_1", price:10},
								"#{add1_2.id}"=> {name: "add1_2", price:20}
								},
								id: pr2.id, name: pr2.name, :price=>15, :count=>2, :all_price=>90,
								},					 
								"#{pr2.id}_#{add1_1.id}"=> 
								{ 
									additionals:
									{ 
										"#{add1_1.id}"=> {name: "add1_1", price:10},
										},
										id: pr2.id, name: pr2.name, :price=>15, :count=>2, :all_price=>50,
										},							
										"#{pr4.id}"=> 
										{ 
											additionals: {},
											id: pr4.id, name: pr4.name, :price=>20, :count=>1, :all_price=>20						  
											}},										
											price: 160, 
											delivery: 0 
											}.to_json)
			expect(manager.add_product("#{pr2.id}_#{add1_1.id}", 1)).to eq(true)
			expect([basket.price,basket.delivery]).to eq([185,0])

			expect(basket.products["#{pr2.id}_#{add1_1.id}"][:additionals].size).to eq(1)
		end
	end

	describe "#add_addition_to_product" do
		it do
			pr2.update(addition_id: add1.id)
			manager.add_product("#{pr2.id}_#{add1_1.id}", 2)
			manager.add_addition_to_product("#{pr2.id}_#{add1_1.id}","#{add1_2.id}")
			expect(basket.products["#{pr2.id}_#{add1_1.id}_#{add1_2.id}"].present?).to eq(true)
			expect(basket.products.count).to eq(1)
		end		
	end

	describe "#remove_addition" do
		it do
			pr2.update(addition_id: add1.id)
			manager.add_product("#{pr2.id}_#{add1_1.id}_#{add1_2.id}",2)
			manager.remove_addition("#{pr2.id}_#{add1_1.id}_#{add1_2.id}","#{add1_1.id}")
			expect(basket.products["#{pr2.id}_#{add1_2.id}"].present?).to eq(true)
			expect(basket.products.count).to eq(1)
		end		
	end

	describe "#remove_product" do
		it do	
			pr2.update(addition_id: add1.id)
			expect(manager.add_product("#{pr2.id}_#{add1_1.id}_#{add1_2.id}_#{add1.id}", 2)).to eq(true)
			expect(manager.add_product("#{pr2.id}_#{add1_1.id}", 2)).to eq(true)
			manager.remove_product("#{pr2.id}_#{add1_1.id}_#{add1_2.id}")			
			expect([basket.price,basket.delivery]).to eq([50,30]) 
		end
	end


	describe "#to_order" do
		let(:data){ {name: 'Fedya', street: 'Kirova', house: '7a', contact_phone: 89508273270} }
		before do
			expect(manager.add_product("#{pr1.id}", 2)).to eq(true)
			expect(manager.add_product("#{pr2.id}_#{add1_1.id}_#{add1_2.id}", 2)).to eq(true)
		end

		it "pr1 is not found" do	
			name1 = pr1.name			
			pr1.destroy			
			expect(manager.to_order).to eq(false)
			expect(manager.errors).to eq(["#{name1} is not available"]) 
		end  
    
    it "check limit order" do
      3.times do
        create(:order, organization_id: org.id, ip: '128.0.0.1')
      end  
      data[:ip] = '128.0.0.1'
      expect(manager.to_order(data)).to eq(false)
      expect(manager.errors).to eq(["Вы превысили лимит заказов. Попробуйте совершить заказ позже."])  
    end

		it "pr2 is not available" do
			pr2.update({active: 0})
			manager.remove_product("#{pr1.id}")
			expect(manager.to_order).to eq(false)
			expect(manager.errors).to eq(["#{pr2.name} is not available"])
		end

		it "Data of order is invalid" do
			expect(manager.to_order).to eq(false)
			expect(manager.errors.count).not_to eq(0) 
		end

		it "The sum of the order is less than minimally allowable one" do
			manager.remove_product("#{pr1.id}")
			expect(manager.to_order(data)).to eq(false)
			expect(manager.errors).to include("The sum of the order is less than minimally allowable one") 
		end

		it "Successfully" do
			pr2.update(addition_id: add1.id)
			expect(manager.add_product("#{pr2.id}_#{add1_1.id}_#{add1_2.id}", 3)).to eq(true)
			expect(manager.to_order(data)).to eq(true)
			expect(manager.errors).to eq([]) 

			order = Order.first 
			expect(order.body).to eq({"products"=>
				{"#{pr1.id}"=>{ "additionals"=> {}, "id"=> pr1.id, "name"=>pr1.name, "price"=>12, "count"=>2, "all_price"=>24},
				"#{pr2.id}"=>{ "additionals"=> {}, "id"=> pr2.id, "name"=>pr2.name, "price"=>15, "count"=>2, "all_price"=>30},
				"#{pr2.id}_#{add1_1.id}_#{add1_2.id}"=>{ 
					"additionals"=>{"2"=>{"name"=>"add1_1", "price"=>10}, "3"=>{"name"=>"add1_2", "price"=>20}},					
					"name"=> pr2.name, "id"=> pr2.id, "price"=>15, "count"=>3, "all_price"=>135},					
					},
					"price"=>189, 
					"delivery"=>0
					}) 
			expect(order.price).to eq(189)
			expect(order.delivery).to eq(0)
		end
	end

end