module TimeRanger
  def days_ranger(count=1)
  	days = []
    time = Time.now
  	count.times do |d|
  		days.push(["#{time.mday} #{(I18n.t('date.abbr_month_names')[time.month])}, #{I18n.t('date.abbr_day_names')[time.wday]}",time.strftime('%Y-%m-%d')])
  		time += 1.day      
  	end
    days
  end
end