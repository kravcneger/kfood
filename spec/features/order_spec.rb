require 'spec_helper'

feature 'Order', :js => true do
  subject { page }
  let!(:org) { create(:organization, min_delivery: 500, delivery: 50, free_shipping: 1000) }

  let!(:cat1){ org.categories.create(name: 'cat1', active: true) }
  let!(:cat1_1){ org.categories.create(name: 'cat1_1', category_id: cat1.id, active: true) }
  let!(:cat1_2){ org.categories.create(name: 'cat1_2', category_id: cat1.id, active: true) }
  let!(:cat2){ org.categories.create(name: 'cat2', active: true) }

  let!(:add1){ org.additions.create(name: 'add1', active: 1) }
  let!(:add1_1){ org.additions.create(name: 'add11', price: 10, addition_id: add1.id, active: 1) }  
  let!(:add1_2){ org.additions.create(name: 'add12', price: 15, addition_id: add1.id, active: 1) }  

  let!(:pr1){ org.products.create(name: 'pr1', price: 20, category_id: cat1.id, active: 1) }
  let!(:pr2){ org.products.create(name: 'pr2', price: 25, category_id: cat1_1, active: 1) }
  let!(:pr3){ org.products.create(name: 'pr3', price: 30, category_id: cat1_1.id, active: 1) }
  let!(:pr4){ org.products.create(name: 'pr4', price: 35, addition_id: add1.id, category_id: cat1_1.id, active: 1) }

  feature "Client" do
    it do
      visit organization_path(org)

      # Adds two product without additions
      first('.product').first('.count').click
      first('.glyphicon-plus').click
      first('.add_product').click
      wait_for_ajax
      expect(first('#basket_panel .price b').text).to eq("#{pr1.price*2} + #{org.delivery}")

      # Adds product when he is unavailable
      pr1.update_attributes({active: 0})
      first('.add_product').click
      expect(page).to have_selector('.simply-toast.alert-danger')
      pr1.update_attributes({active: 1})

      # Adds product with additions
      first('#menu li').click
      wait_for_ajax
      first('#menu li .nav li').click
      wait_for_ajax
      page.first(".product_additions").click

      # first('.product_additions').click
      wait_for_ajax
      page.find("#addition_ids_#{add1_1.id}").click
      page.find("#addition_ids_#{add1_2.id}").click

      expect( first('.additions_block .price i').text ).to eq("#{add1_1.price+add1_2.price}")
      expect( first('.additions_block .total i').text ).to eq("#{pr4.price+add1_1.price+add1_2.price}")

      first('.additions_block #count').set(3)
      expect( first('.additions_block .price i').text ).to eq("#{(add1_1.price+add1_2.price)*3}")
      expect( first('.additions_block .total i').text ).to eq("#{(pr4.price+add1_1.price+add1_2.price)*3}")

      first('.additions_block .btn-sm').click
      wait_for_ajax
      expect(first('#basket_panel .price b').text).to eq("#{pr1.price*2 + (pr4.price+add1_1.price+add1_2.price)*3} + #{org.delivery}")

      # Open basket
      first('.open_basket').click
      wait_for_ajax
      expect( find('.first-step') ).to have_content(pr1.name)
      expect( find('.first-step') ).to have_content(pr4.name)
      wait_for_ajax

      # Destroy product
      first(:xpath, "//a[@class='remove_product'][@data-id='#{pr1.id}']").click
      wait_for_ajax
      expect( find('.first-step') ).not_to have_content(pr1.name)
      # expect( first('#basket_panel .price b').text ).to eq("#{(pr4.price+add1_1.price+add1_2.price)*3} + #{org.delivery}")

      # Destroy addition
      first(:xpath, "//span[@class='additions']/*/span[@data-id='#{add1_2.id}']").click
      wait_for_ajax
      expect( find('.first-step') ).not_to have_content(add1_2.name)
      # expect( first('#basket_panel .price b').text ).to eq("#{(pr4.price+add1_1.price)*3} + #{org.delivery}")

      # Change counter
      page.execute_script("$('.product_position input:eq(1)').val('30').change();")
      wait_for_ajax

   #   expect(page.find('#basket_panel .price b').reload.text).to eq("1350 + 0")
      expect([first('#custom .order_info span b').text,first('#custom .order_info div h3 b').text]).to eq(['1350','1350'])  

      # Go to second step without contact_phone
      first('.go-to-second-step').click
      wait_for_ajax 
      first('#order_name').set('Фёдор')
      first('#order_street').set('Sulimova')
      first('#order_house').set('8a')
      first('#order_apartment').set('70')
      first('#order_floor').set('12')
      first('#order_building').set('1')
      first('#order_entrance').set('1')
      first('#order_access_code').set('123')
      first('#order_renting').set('500')
      find(:xpath, "//input[@name='order[to_checkbox]'][@value='1']").click
      find(:xpath, "//select[@id='order_to_day']").find(:xpath, 'option[3]').select_option
      find(:xpath, "//select[@id='order_to_hours']").find(:xpath, 'option[2]').select_option
      find(:xpath, "//select[@id='order_to_minutes']").find(:xpath, 'option[2]').select_option
      first('.to-order').click
      
      wait_for_ajax
      expect( find('.errors').find('.text-danger')).not_to eq('')
      
      # Go to second step with contact_phone
      page.execute_script("$('#order_contact_phone').val('9508272222');")
      page.execute_script("$('.to-order').trigger('click');")
      wait_for_ajax

      expect(page).to have_selector('#basket_panel', visible: false)      

      ord = org.reload.orders.reload.last
      expect( ord.price ).to eq(1350)
      expect( ord.delivery ).to eq(0)
      expect( ord.name ).to eq('Фёдор')
      expect( ord.street ).to eq('Sulimova')
      expect( ord.house ).to eq('8a')
      expect( ord.addition_info ).to eq({'apartment'=> '70',
       'floor'=> '12',
       'building'=> '1', 
       'entrance'=> '1', 
       'access_code'=> '123',
       'renting'=> '500'})

      expect( ord.body ).to eq(
       { "products" =>
        {"3_2" => 
         {"additionals"=>
          {"2"=>
           {"name"=>"add11", "price"=>10}},
           "id" => pr4.id,
           "name"=>"pr4",
           "price"=>35,
           "count"=>30,
           "all_price"=>1350
           }},
           'price' => 1350,
           'delivery' => 0,
           })  
      t = Time.now + 2.days
      expect( ord.time_order.to_s(:db) ).to eq( Time.new(t.year, t.month, t.day, '01', '10').to_s(:db) )      
    end
  end


  feature "Admin" do
    let!(:basket){ Basket.new }

    before do
      manager_order = ManagerOrder.new(org, basket)
      manager_order.add_product("#{pr1.id}",2)
      manager_order.add_product("#{pr4.id}_#{add1_1.id}_#{add1_2.id}",2)
      7.times do |i|
        org.orders.create(name: "name#{i}", contact_phone: "8950000000#{i}", street: "street#{i}", house: i,
          body: basket.to_json,
          price: basket.price,
          delivery: basket.delivery)
      end
      sleep 1
      org.orders.create(name: "name9", contact_phone: "89500000009", street: "street9", house: '9',
        body: basket.to_json,
        price: basket.price,
        delivery: basket.delivery)      
    end

    it do
      visit orders_path
      expect(page).to have_content("Вход в панель")
    end

    feature "Sign_in" do
      let(:finalPrice){ Proc.new { first(:xpath, "//h4[@class='final_price']/span").text.to_i } }
      before do
        sign_in org     
        visit orders_path
      end

      it "Browsing orders" do
        expect(page).to have_selector('tr.ord.active', count: 8)
      end
      
      it "Check notification .new_order" do
        sleep 6
        expect(page).to have_selector('.simply-toast.new_order')
        expect(['***', 'Новые заказы'].include?(page.title)).to eq(true)
      end

      it "Change viewed status after opening order" do 
        first('.glyphicon-folder-open').click
        sleep 0.4
        expect(page).to have_selector('tr.ord.active', count: 7)
        expect(first('#name').value).to eq('name9')
      end

      it "Edit order" do 
        final_price = basket.price+basket.delivery
        first('.glyphicon-folder-open').click
        sleep 1
        first(:xpath, "//a[@href='#products-data']").click
        expect(all('.position').count).to eq(2)
        expect(finalPrice.call).to eq(final_price)
        
        # Remove product
        first('.remove_position').click
        sleep 1
        final_price -= 120        
        expect(all('.position').count).to eq(1)
        expect(first(:xpath, "//input[@id='price']").value.to_i).to eq(final_price-org.delivery)
        expect(finalPrice.call).to eq(final_price)

        # Search product
        page.execute_script("$('#search_product').val('pr').keyup();")
        sleep 3
        expect(page.first('#search_result')).to have_selector('.detected_product', count: 3)
        # Add product found.        
        page.find(:xpath, "//a[@data-id='#{pr4.id}']").click
        sleep 0.5
        final_price += 35 

        expect(finalPrice.call).to eq(final_price)
        expect(all('.position').count).to eq(2)
        
        # Add two addions

        first('.select_addition').hover     
        wait_for_ajax
        final_price += add1_1.price+add1_2.price
        expect(first('.select_addition').all('option').count).to eq(3) 
        
        first('.select_addition').all('option')[1].select_option
        
        first('.select_addition').all('option')[2].select_option

        expect(finalPrice.call).to eq(final_price) 
        expect(first('.position').first('span.price').text.to_i).to eq(pr4.price+add1_1.price+add1_2.price) 
        
        # Remove addition
        first('.remove_addition').click
        final_price -= add1_2.price 
        expect(first('.position').first('span.price').text.to_i).to eq(pr4.price+add1_1.price)
        expect(finalPrice.call).to eq(final_price) 
        
        # Change count        
        page.execute_script("$('.position .count input:eq(0)').val('20').change();")
        page.execute_script("$('.position .count input:last').val('10').change();")

        sleep 0.2
        expect(page.first('.position').first('span.price').text.to_i).to eq( 20 * (pr4.price+add1_1.price))
        final_price = 10 * pr1.price + 20 * (pr4.price + add1_1.price )
        expect(finalPrice.call).to eq(final_price)
        expect(first(:xpath, "//input[@id='delivery']").value.to_i).to eq(0)
        

        # Change name and save result
        first(:xpath, "//a[@href='#order-data']").click
        first('#name').set('Vasya')
        first('#orderDialog').first('.btn-warning').click
        sleep 2
        expect(page).not_to have_selector('.modal-dialog')
        expect(first('.ord')).to have_content('Vasya')
        expect(org.orders.last.body).to eq({ "products"=>
          {"1"=>
            {"id"=>"#{pr4.id}", "price"=>"#{pr4.price}", "name"=>"pr4", "count"=>"20", "all_price"=>"#{(pr4.price+add1_1.price)*20}", "additionals"=>
            {"0"=>
              {"name"=>"add11", "price"=>"#{add1_1.price}"}
            }
            }, 
            "0"=>
            {"id"=>"#{pr1.id}", "price"=>"#{pr1.price}", "name"=>"pr1", "count"=>"10", "all_price"=>"#{pr1.price*10}"
          }
        }
        })
      end

      it "Remove and restore orders" do
        first('.btn-danger.destroy').click
        sleep 1
        first('.btn-danger.destroy').click
        sleep 1

        expect(page).to have_selector('.ord', count: 6)        
        visit orders_path(type: 'basket')
        expect(page).to have_selector('.ord', count: 2) 
        
        # Restore
        first('.btn.restore').click
        sleep 1
        first('.btn.restore').click
        sleep 1 
        expect(page).not_to have_selector('.ord')        
      end

    end

  end

end