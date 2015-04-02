require 'spec_helper'

feature 'Categories', :js => true do
	subject { page }
	let(:org) { create(:organization) }
	let!(:cat1){ org.categories.create(name: 'cat1', active: true) }
	let!(:cat1_1){ org.categories.create(name: 'cat1_1', category_id: cat1.id, active: true) }
	let!(:cat1_2){ org.categories.create(name: 'cat1_2', category_id: cat1.id, active: false) }
	let!(:cat2){ org.categories.create(name: 'cat2', active: false) }

	it 'View categories' do
		sign_out
		visit organization_path(org)
		expect(page).to have_selector('#menu li', :visible => false, count: 2)
	end

	feature 'Signing in' do
		before do
			sign_in org			
			visit organization_path(org)
		end

		it 'View categories' do
			visit organization_path(org)
			expect(page).to have_selector('#menu li', :visible => false, count: 4)
		end

		it 'View categories of other organization' do
			org2 = create(:organization)
			org2.categories.create!(name: 'cat1', active: false)
			visit organization_path(org2)
			expect(page).to have_selector('#menu li', count: 0)
		end

		it 'Check selects selectors' do
			first('.new_cat').click
      # проверка открытия окна
      expect(page).to have_selector('#myModal')
      # проверка списка доступных категорий для указания порядка вставки
      expect(all('#category_after_category option')[-1].value).to eq("#{cat2.id}")
      select cat1.name, :from => 'category_category_id'
      sleep 1
      expect(all('#category_after_category option')[-1].value).to eq("#{cat1_2.id}")
    end

    feature 'Create new category' do 
    	before do 
    		first('.new_cat').click
    		sleep 1
    	end   	
    	scenario 'invalid' do
    		first('#save_category').click
    		sleep 1
    		expect(first('#myModal div.errors').text.lstrip).not_to eq('')
    	end
    	scenario 'valid' do
    		first('#category_name').set('new_cat')
    		page.execute_script("$('#save_category').trigger('click')")

    		sleep 1
    		expect(org.categories_all.count).to eq(5)
    		expect(page).to have_selector('#menu li', visible: false, count: 5)
    		expect(all('#menu li').last.text).to match('new_cat')
    	end
    end

    feature 'edit category' do
    	scenario 'new parent' do
        click_category cat1_1, 'glyphicon-pencil'

        sleep 1
        first('#category_name').set('new_cat')
        # у первой дочерней категори  cat1_1
        # меняется предок с cat1 на cat2 

        find('#category_category_id').find("option[value='#{cat2.id}']").select_option
        page.execute_script("$('#save_category').trigger('click')")
        sleep 2

        expect(cat2.children.count).to eq(1)
        expect(page).to have_selector('#menu li', count: 3)
        expect(first(:xpath, "//li[@data-id='#{cat1_1.id}']//span[@class='title']").text).to eq('new_cat')

        # Проверяем работает ли диалоговое окно у улемента после сохранения 
        # и отображается ли новый результат в окне
        click_category cat1_1, 'glyphicon-pencil'
        sleep 1
        expect(first('#myModal #category_name').value).to eq('new_cat')    
      end
    end

    it 'toggle active' do
      click_category cat1_2, 'toggle_publish'
      sleep 1
      expect(page).to have_selector('li.sub_category.off', count: 0)
      expect(org.categories.count).to eq(3)

      # toggle parent cat
      click_category cat1, 'toggle_publish'
      sleep 1
      expect(page).to have_selector('#menu li.off', count: 4)
      expect(org.categories.count).to eq(0) 
      
      # публикация дочернего элемента когда родительский не опубликован
      click_category cat1_1, 'toggle_publish'
      sleep 1
      page.driver.browser.switch_to.alert.accept
      sleep 1
      expect(page).to have_selector('#menu li.off', count: 4)
    end	

    it 'remove' do
      click_category cat1, 'glyphicon-remove'
      page.driver.browser.switch_to.alert.accept
      sleep 1
      expect(page.driver.browser.switch_to.alert.text).to eq(I18n.t('category_have_sub_categories'))      
      page.driver.browser.switch_to.alert.accept
      # remove sub_category
      click_category cat1_1, 'glyphicon-remove'
      sleep 1
      page.driver.browser.switch_to.alert.accept
      sleep 1
      expect(page).to have_selector('#menu li', visible: false, count: 3)
      expect(org.categories_all.count).to eq(3)
    end

  end
end
