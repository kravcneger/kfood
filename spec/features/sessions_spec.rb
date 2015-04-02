require 'spec_helper'

feature "Sessions" do
	subject { page }
	feature "signin" do
		before { visit new_organization_session_path }

		feature "with invalid information" do
			before  do
				fill_in "organization_email", with: "example@example.org"
				fill_in "organization_password", with: "12345678"
				click_button 'sign_in'
			end
			it{ expect(page.text).to match(/Invalid email or password./) }
		end

		feature "with valid information" do
			let(:organization) { create(:organization, name: 'Gey cafe', :email => 'example@example.org') }
			before  do
				sign_in organization
			end
			it{ expect(page.text).to match(organization.name) }
		end		
	end
end