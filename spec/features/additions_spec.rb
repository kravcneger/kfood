require 'spec_helper'

feature 'Additions', :js => true do
	subject { page }
	let!(:org) { create(:organization) }

	it 'View additions' do
		sign_out
		visit organization_path(org)
		expect(page).not_to have_selector('#show_additions')
	end

	feature 'Control additions' do
		let!(:add1) { create(:addition, organization_id: org.id, active: true, name: 'add1') }
		before do
			sign_in org			
			visit organization_path(org)
			first('#show_additions').click
			sleep 0.4
		end

		it { expect(first('#additions li').text).to match(add1.name) }

		feature "Create new addition" do	
			before do		  
				first('#new_addition').click
				sleep 0.4
			end

			it 'with invalid informations' do	
				first('#save_addition').click
				sleep 0.4
				expect(first('#myModal div.errors').text.lstrip).not_to eq('')
			end 

			it 'with valid parent addition' do
				first('#addition_name').set('add2')
				sleep 0.4
				page.execute_script("$('#save_addition').trigger('click')")
				sleep 1
				expect(org.additions_all.count).to eq(2)
				expect(all('#additions li').last.text).to match('add2')
			end 

			it 'with valid sub_category' do
				find('#addition_addition_id').find("option[value='#{add1.id}']").select_option
				first('#addition_name').set('add1_2')
				sleep 1
				page.execute_script("$('#save_addition').trigger('click')")
				sleep 1
				expect(all('#additions li').count).to eq(2)
				expect(page.all('#additions li li').last.text).to match('add1_2')   
			end   
		end

		feature "update" do
			before do
				page.execute_script("$('#additions li span.glyphicon-pencil:first').trigger('click')")
				sleep 0.4
			end

			it do 
				first('#addition_name').set('picci')
				sleep 1
				page.execute_script("$('#save_addition').trigger('click')")
				sleep 1
				expect(all('#additions li').last.text).to match('picci') 
			end
		end	

		feature "toggle" do
			let!(:add1_2) { create(:addition, organization_id: org.id, name: 'add1_2', active: true, addition_id: add1.id) }
			before do
				first('body').click
				first('#show_additions').click
				sleep 1				
			end

			it 'parent' do
				page.execute_script("$('#additions li:nth-child(1) span.toggle_publish:first').click();")
				sleep 1
				expect(page).to have_selector('#additions li.off', visible: false, count: 2)
				expect(org.additions.count).to eq(0)       

				page.execute_script("$('#additions li li:nth-child(1) span.toggle_publish:first').click();")
				sleep 0.1 
				expect(page.driver.browser.switch_to.alert.present?).to eq(true)   
				page.driver.browser.switch_to.alert.accept
				expect(page).to have_selector('#additions li.off', visible: false, count: 2)
			end
		end

		feature "destroy" do
			let!(:add1_2) { create(:addition, organization_id: org.id, name: 'add1_2', active: true, addition_id: add1.id) }
			before do
				first('body').click
				first('#show_additions').click
				sleep 0.4				
			end

			it do
				page.execute_script('window.confirm = function() { return true; }')
				page.execute_script("$('#additions li span.glyphicon-remove:first').click();") 
				sleep 0.4
				expect(org.additions_all.count).to eq(0)  
				expect(page).to have_selector('#additions li', visible: false, count: 0)
			end
		end

	end
end