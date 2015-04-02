class Schedule < ActiveRecord::Base
	include OrganizationRelative

  validates :day, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 6 }
  validates :is_holiday, inclusion: { in: [true] }, allow_nil: true
  
  scope :orders, -> { order('day asc, first_time asc') }

  before_validation do
    if is_holiday?
      self.first_time = nil
      self.second_time = nil
    end
  end

  after_save do
    unless is_holiday?
      Schedule.where(organization_id: organization_id.to_i, day: day.to_i, is_holiday: true).destroy_all
    end
  end

  with_options unless: 'is_holiday?' do |schedule|
    schedule.validates :first_time, :second_time, format: { with: /\A((0[0-9]|1[0-9]|2[0-3]):[0-5][0-9])\z/ }
    schedule.validate :time    
  end

  def overlap?(range)
    s_first_time = self.first_time.delete(':').to_i
    s_second_time = self.second_time.delete(':').to_i
    r_first_time = range.first_time.delete(':').to_i
    r_second_time = range.second_time.delete(':').to_i

    s_first_time.between?(r_first_time,r_second_time) || s_second_time.between?(r_first_time,r_second_time) || 
    r_first_time.between?(s_first_time,s_second_time) || r_second_time.between?(s_first_time,s_second_time)
  end

  private 
  
  def time
    if [0,1].include?(first_time <=> second_time)
      errors[:first_time] << "First time must be less than second_time"
      return false
    end

    return unless errors.blank?    

    Schedule.where(organization_id: organization_id.to_i, day: day.to_i).each do |range|      
      if range.id != self.id 
        # Если время создаваемого диапазон пересекатся с одним
        # Из уже существующих
        if !range.is_holiday? && self.overlap?(range)
          errors[:base] << "Time rangers should not overlap"
          return false
        end
      end 
    end
  end
end