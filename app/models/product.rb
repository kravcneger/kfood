class Product < ActiveRecord::Base
	include OrganizationRelative

	has_attached_file :avatar, :styles => { :thumb => ["320x320>", :png], :preview => ["200x200>", :png] }, :default_url => ":style.png"
	validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

	belongs_to :category, ->(product) { self_organization(product) }
	belongs_to :addition, ->(product) { self_organization(product) }
	validates :category_id, presence: true

	validates :name, presence: true, length: { minimum: 2, maximum: 200 }  
	validates :price, presence: true, numericality: { only_integer: true, less_than: Kfood::Application.config.max_integer }

	validates :description, length: { maximum: 600 }	
	validates :calories, :weight, numericality: { only_integer: true, less_than: Kfood::Application.config.max_integer }, :allow_nil => true
	
	validate :check_category
	validate :check_active
	validate :check_addition

	scope :published_products, -> { where(" active = 1 OR active = 2 ") }
  scope :orders, ->(field='name', by = 'ASC') do  
    field.to_s.downcase!
    by.to_s.downcase!
    str = 'active <> 0 desc,'
    str +=  ['name', 'price', 'calories', 'weight'].include?(field.to_s) ? field.to_s : 'name'
    str += by.to_s == 'desc' ? ' desc' : ' asc'
    order(str) 
  end


  # Defines condition of product
  # 1 - visible
  # 2 - visible but not available for order
  # 0 - invisible
  def status
  	if active == 1
  		return 1
  	elsif active == 2 and locked_to > Time.now.to_s(:db)
  		return 2
  	elsif active == 2 and locked_to < Time.now.to_s(:db)
  		return 1	
  	else
  		return 0
  	end
  end

  def available_to_order?
    status == 1
  end

  def time_locked_to
    locked_to.nil? ? '' : Time.parse(locked_to.to_s).strftime('%Y-%m-%d %H:%M')
  end

  private 
  
  def check_active
  	if self.active == 2 
  		if locked_to.nil?
  			errors.add(:locked_to, 'can not be null')
  		else 
  			begin
  				self.locked_to = Time.parse(self.locked_to.to_s)
  			rescue
          errors.add(:locked_to, 'incorrect time')
        end
      end      
    else
      self.locked_to = nil
    end
  end

  def check_category
    if self.category.blank?
      errors.add(:category_id, 'incorrect category')
    end
  end

  def check_addition
    if !self.addition_id.nil? && self.addition_id != 0 && self.addition.blank?    	
      errors.add(:addition_id, 'incorrect addition') 
    elsif self.addition.present?
      if self.addition.is_sub?
        errors.add(:addition_id, 'addition is sub') 
      end
    end 
  end
end