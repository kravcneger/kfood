require 'spec_helper'

feature "Sessions" do
	subject { page }
	feature "signin" do
		let(:organization) { create(:organization, name: 'Gey cafe', :email => 'example@example.org') }
		before { sign_in organization }
	end
end