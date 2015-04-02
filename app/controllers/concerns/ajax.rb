module Ajax
	extend ActiveSupport::Concern

	included do
  	def is_ajax?
  		redirect_to :back and return unless request.xhr?
  	end		
  end
end