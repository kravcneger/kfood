class MainController < ApplicationController
  def index
  	@organizaztions = Organization.where(published: true)
  end
end
