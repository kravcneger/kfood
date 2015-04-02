# 12 columns without timestamps

class Order < ActiveRecord::Base
	belongs_to :organization
	validates :organization_id, presence: true	
	validates :name, :street, :house, presence: true, length: { minimum: 1, maximum: 100 }  
	
  validates :contact_phone, presence: true, numericality: { only_integer: true }, length: { is: 11 }
  
  validates :addition_info, length: { maximum: 600 }  

  validates :time_order, length: { maximum: 600 }  


  validates :comment, length: { maximum: 300 }  
  
  validates :body, presence: true

  validates :price, :delivery, presence: true, numericality: { only_integer: true }
  
  validates :viewed, :notified, :inclusion => {:in => [true, false]}
  
  validates :status, presence: true, numericality: { only_integer: true }, length: { is: 1 }
  
  attr_accessor :building, :apartment, :entrance, :floor, :access_code, :renting
  
  before_validation do
    self.addition_info = {}
    self.addition_info[:building] = self.building
    self.addition_info[:apartment] = self.apartment
    self.addition_info[:entrance] = self.entrance
    self.addition_info[:floor] = self.floor
    self.addition_info[:access_code] = self.access_code
    self.addition_info[:renting] = self.renting
  end

end