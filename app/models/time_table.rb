class TimeTable
	def initialize(organization)
		@organization = organization
	end

  # Проверяет работает ли организация в данный момент
  # Если нет временных диапазнов по текущему дню недели то орг. работае круглосуточно
  def is_work?
  	schedules = @organization.schedules.where(day: Time.now.wday)
  	return true if schedules.blank?

  	time_str = Time.now.strftime('%H:%M')

  	schedules.each do |s|
  		return false if s.is_holiday?
  		return true if([0,1].include?(time_str <=> s.first_time) and [0,-1].include?(time_str <=> s.second_time))
  	end
  	false
  end

  def set_holiday(day)
  	return unless day.between?(0,6)
  	Schedule.transaction do 
  		@organization.schedules.where(day: day).delete_all
  		@organization.schedules.create!(day: day, is_holiday: true)
  	end	
  end

  def set_around(day)
  	return unless day.between?(0,6)
  	@organization.schedules.where(day: day).delete_all
  end

  def get_table
  	days = Array.new(7)
  	@organization.schedules.each do |sch|
  		if sch.is_holiday?
  			days[sch.day] = false
  			next
  		end
  		days[sch.day] ||= ''
  		days[sch.day] += days[sch.day] != '' ? ' | ' : ''
  		days[sch.day] += sch.first_time + ' - ' + (sch.second_time == '23:59' ? '00:00' : sch.second_time)
  	end 
  	days
  end

  def list_schedules
    days = Array.new(7)
    @organization.schedules.each do |sch|
      if sch.is_holiday?
        days[sch.day] = false
        next
      end
      days[sch.day] ||= []
      days[sch.day].push(sch)
    end
    days
  end

end