module Access
	extend ActiveSupport::Concern

	included do
  	#	before_action :can_do, only: [:new, :create, :edit, :update, :destroy]
  	def available_control?
  		organization_signed_in? and (current_organization.id == @organization.id)
  	end	

    def current_organization?
      redirect_to root_path and return unless available_control?
    end	
  end

  private

  module ClassMethods

  end
end