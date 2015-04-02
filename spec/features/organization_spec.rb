require 'spec_helper'

feature 'Organization', :js => true do
	subject { page }
	let!(:org) { create(:organization, email: 'email@email.org', password: 'password', password_confirmation: 'password') }

	it "showing edit page when user is not authorized" do
		visit edit_organization_path(org, 'info')
		expect(page).not_to have_xpath("//input[@value='#{org.name}']")
	end

	it "showing alien edit page when user is authorized" do    
		org2 = create(:organization)
		sign_in org
		visit edit_organization_path(org2, 'info')
		expect(page).not_to have_xpath("//input[@value='#{org.name}']")
	end
  
  it 'showing message of after hours' do
    org.timetable.set_holiday(Time.now.wday)
    visit organization_path(org)
    expect(page).to have_selector('.simply-toast.alert-danger') 
  end

	it "showing edit page" do    
		sign_in org
		visit edit_organization_path(org, 'info')
		expect(page).to have_xpath("//input[@value='#{org.name}']")
	end

	feature 'update info' do
		before do
			sign_in org
			visit edit_organization_path(org, 'info')
		end

		it 'with invalid information' do
			first('#organization_name').set('')
			click_button 'Сохранить'
			expect(page).to have_xpath("//div[@class='alert alert-danger']")
		end

		it 'with valid information' do
			first('#organization_name').set('Name2')
			click_button 'Сохранить'
			expect(org.reload.name).to eq('Name2')
			expect(page).to have_xpath("//div[@class='alert alert-success']")
		end
	end

	feature 'update auth data' do
		before do
			sign_in org
			visit edit_organization_path(org, 'auth')
		end

		it 'without input of current_password' do
			first('#organization_email').set('email@email.com')
			click_button 'Сохранить'
			expect(page).to have_xpath("//div[@class='alert alert-danger']")
		end

		it 'without input of current_password' do
			first('#organization_email').set('email@email.com')
			first('#organization_current_password').set('password')
			click_button 'Сохранить'
			expect(org.reload.email).to eq('email@email.com')
			expect(page).to have_xpath("//div[@class='alert alert-success']")
		end
	end

	feature 'update block' do
		before do
			sign_in org
			visit edit_organization_path(org, 'block')
		end

		it 'with invalid information' do
			expect(first('#organization_published').checked?).to eq(false)
		end

		it do
			first('#organization_published').set(true)
			first('#organization_message_block').set('Санитарный день')
			click_button 'Сохранить'
			expect(page).to have_content('заблокирован')
			expect(org.reload.published).to eq(false)
		end

	end

end