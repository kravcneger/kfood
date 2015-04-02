include Warden::Test::Helpers

def sign_in(organization)  
	visit new_organization_session_path
	fill_in "organization_email", with: organization.email
	fill_in "organization_password", with: organization.password
	click_button 'sign_in'     
end

def sign_out
	if all('#sign_out').present?
		first('#sign_out').click
	end
end

def sample_file(filename = "sample_file.png")
	File.new("test/fixtures/#{filename}")
end

def click_category(cat, icon)
	if cat.is_sub?
		first(:xpath, "//li[@data-id='#{cat.parent.id}']/a").click
		sleep 1.5
	end

	if icon
		first(:xpath, "//li[@data-id='#{cat.id}']/a").hover
		first(:xpath, "//li[@data-id='#{cat.id}']/a").first(".#{icon}").click
	else
		first(:xpath, "//li[@data-id='#{cat.id}']").click
	end

end
