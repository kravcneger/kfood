class Organization < ActiveRecord::Base
  include Tree
  include OrganizationAuthData
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :trackable, :validatable

  has_attached_file :avatar, :styles => { :preview => ["140x140>", :png], :thumb => ["350x350>", :png] }, :default_url => ":style.png"
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  validates :name, presence: true, length: { minimum: 4, maximum: 128 }  
  validates :additional_information, :social_networks, :map_code, length: { maximum: 400 }, :allow_blank => true  
  validates :premature_notification, presence: true, numericality: { only_integer: true, less_than: 24 }  

  with_options unless: 'map_code_change.blank?' do |org|
    org.validate :check_map
  end
  validates :push_key1, :push_key2 , length: { maximum: 100 }, :allow_blank => true 

  validates :description, length: { maximum: 5000 }, :allow_blank => true 
  validates :message_block, length: { maximum: 200 }, :allow_blank => true 
  validates :addresses, length: { maximum: 5000 }, :allow_blank => true

  validates :delivery, :min_delivery, :free_shipping, presence: true, numericality: { only_integer: true, less_than: Kfood::Application.config.max_integer } 
  before_validation do 
    self.delivery ||= 0
    self.min_delivery ||= 0
    self.free_shipping ||= 0
  end

  has_many :categories, -> { orders.published }
  has_many :categories_all, -> { orders }, class_name: :Category, dependent: :destroy

  has_many :additions, -> { published.orders }
  has_many :additions_all, -> { orders }, class_name: :Addition, dependent: :destroy

  has_many :products, dependent: :destroy
  has_many :schedules, -> { orders }, dependent: :destroy

  has_many :orders

  def get_menu(params={})
    if params.to_s == 'all' 
      list = self.categories_all
    else
      list = self.categories 
    end
    self.get_tree(list)
  end

  def get_additions(params={})
    if params.to_s == 'all' 
      list = self.additions_all
    else
      list = self.additions 
    end
    self.get_tree(list)
  end

  def timetable
    @timetable ||= TimeTable.new(self)
  end
  
  def premature_notification
    @premature_notification ||= 1
  end
  
  def premature_orders
    self.orders.where(status: 1).where("time_order BETWEEN '#{(Time.now).to_s}' AND '#{(Time.now+self.premature_notification.hours).to_s}'").order("time_order ASC")
  end

  private
  
  def check_map
    self.map_code = /sid=(.*?)&/.match(map_code)
    if self.map_code.nil?      
      errors.add(:map_code, 'is invalid')  
    else
      self.map_code = self.map_code[1]    
    end
  end

end
