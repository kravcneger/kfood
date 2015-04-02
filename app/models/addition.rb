class Addition < ActiveRecord::Base
	include OrganizationRelative
	include Active
	include Tree

	validates :name, presence: true, length: { minimum: 2, maximum: 100 }  
	validates :addition_id, :price, numericality: { only_integer: true, less_than: Kfood::Application.config.max_integer  }, :allow_nil => true
	validate :addition_id, :move

	has_many :children_all, ->(add) { self_organization(add) }, class_name: :Addition, foreign_key: "addition_id", dependent: :destroy
	has_many :children, ->(add) { self_organization(add).published }, class_name: :Addition, foreign_key: "addition_id", dependent: :destroy
	
	belongs_to :parent, class_name: "Addition", foreign_key: "addition_id"

  scope :orders, -> { order('addition_id asc,name asc') }
end