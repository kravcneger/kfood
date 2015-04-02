require 'spec_helper'

feature 'TimeTable', :js => true do
	subject { page }
	let!(:org) { create(:organization) }
	let!(:range) { create(:schedule, organization_id: org.id, day: 2, first_time: '10:00', second_time: '14:00' ) }
	let!(:range2) { create(:schedule, organization_id: org.id, day: 2, first_time: '14:10', second_time: '15:00' ) }

	let(:table_edit){ '.time_table_edit' }
	let(:day_row) { Proc.new { |day| first(:xpath, "//div[@class='form-group'][@data-day='"+day.to_s+"']") } }

	before do
		sign_in org
		first('a.edit_timetable').click
		sleep 1
	end

	it 'Check existence of rangers' do
		expect(day_row.call(1)).to have_selector(:xpath,"//input[@value='10:00']")
	end

	it 'Create invalid range' do
		day_row.call(1).first('.new_range').click 
		expect(day_row.call(1).first('.new.range')).to have_selector('input')

		day_row.call(1).first('.glyphicon-refresh').click
		sleep 1
		expect(first(table_edit).first('.errors').text.lstrip).not_to eq('')

		day_row.call(1).all('input')[0].set('10:10')
		day_row.call(1).all('input')[1].set('10:00')
		day_row.call(1).first('.glyphicon-refresh').click
		sleep 1 	
		expect(first(table_edit).first('.errors').text.lstrip).not_to eq('')	
	end

	it 'Create valid range' do		
		first('a.new_range').click

		page.execute_script("$('.new.range input:eq(0)').val('1000');")
		page.execute_script("$('.new.range input:eq(1)').val('12:00');")

		page.find('.new.range').first('.glyphicon-refresh').click
		sleep 2   

		first('a.new_range').click
		page.execute_script("$('.new.range input:eq(0)').val('1300');")
		page.execute_script("$('.new.range input:eq(1)').val('14:00');")

		page.find('.new.range').first('.glyphicon-refresh').click
		sleep 2

		expect(first(table_edit).first('.errors').text.lstrip).to eq('')
		expect(first(table_edit)).to have_selector(:xpath,"//input[@value='10:00']")
		expect(org.schedules.where(day: 1).count).to eq(2)
	end	

	it 'Update range' do
		page.execute_script("$('#{table_edit} span[data-id=#{range.id}] input:eq(0)').val('08:00');")
		page.execute_script("$('#{table_edit} span[data-id=#{range.id}] input:eq(1)').val('09:00');")

		first('.range').first('.glyphicon-refresh').click
		sleep 1 

		expect(first(table_edit).first('.errors').text.lstrip).to eq('')
		expect(org.schedules.where(day: 2).first.first_time).to eq('08:00')		
	end

	it 'Destroy range' do
		expect do 
			first('.glyphicon-remove').click
			sleep 1
		end.to change{org.schedules.where(day: 2).count}.by(-1)
		expect(all('.range').count).to eq(1)
	end

	it 'Set holiday' do
		expect do 
			day_row.call(2).first('.set_holiday').click
			sleep 1 
		end.to change{org.schedules.where(day: 2).count}.by(-1)
		expect(day_row.call(2)).not_to have_selector('input')
		expect(org.schedules.where(day: 2).first.is_holiday?).to eq(true)
	end
	
	it 'Set Around' do
		expect do 
			day_row.call(2).first('.set_around').click
			sleep 1 
		end.to change{org.schedules.where(day: 2).count}.by(-2)
		expect(day_row.call(2)).not_to have_selector('input')
		expect(org.schedules.where(day: 2).count).to eq(0)
	end

end