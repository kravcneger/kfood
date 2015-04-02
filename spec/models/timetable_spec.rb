require 'spec_helper'

describe TimeTable do
	let(:org){ create(:organization) }
	let(:org2){ create(:organization) }

	subject { org }

	describe 'Works' do
		let!(:schedule){ create(:schedule, organization_id: org.id, day: Time.now.wday, first_time: (Time.now - 2*60).strftime('%H:%M'), second_time: (Time.now + 2*60).strftime('%H:%M')) }
		it{ expect(org.timetable.is_work?).to eq(true) }
	end

	describe 'Doesn`t work' do
		let!(:schedule){ create(:schedule, organization_id: org.id, day: Time.now.wday, first_time: (Time.now + 2*60).strftime('%H:%M'), second_time: (Time.now + 4*60).strftime('%H:%M')) }
		it{ expect(org.timetable.is_work?).to eq(false) }
	end
	
	describe 'Holiday' do
		let!(:schedule){ create(:schedule, organization_id: org.id, day: Time.now.wday, is_holiday: true) }
		it{ expect(org.timetable.is_work?).to eq(false) }
	end

	describe '#set_holiday' do
		let!(:schedule){ create(:schedule, organization_id: org.id, day: Time.now.wday, first_time: (Time.now - 2*60).strftime('%H:%M'), second_time: (Time.now + 2*60).strftime('%H:%M')) }
		let!(:schedule){ create(:schedule, organization_id: org.id, day: Time.now.wday, first_time: (Time.now + 2*60).strftime('%H:%M'), second_time: (Time.now + 4*60).strftime('%H:%M')) }
		it do
			org.timetable.set_holiday(Time.now.wday)
			expect(org.timetable.is_work?).to eq(false) 
			expect(org.schedules.count).to eq(1) 
		end
	end

	describe do		
		let!(:sch1){ create(:schedule, organization_id: org.id, day: 2, first_time: '16:00', second_time: '18:00') }
		let!(:sch2){ create(:schedule, organization_id: org.id, day: 2, first_time: '10:00', second_time: '14:00') }
		let!(:sch3){ create(:schedule, organization_id: org.id, day: 1, first_time: '16:00', second_time: '18:00') }
		let!(:sch4){ create(:schedule, organization_id: org.id, day: 1, first_time: '10:00', second_time: '14:00') }
		before do
			org.timetable.set_holiday(4)
		end
		it '#get_table' do
			expect(org.timetable.get_table).to eq([nil, '10:00 - 14:00 | 16:00 - 18:00','10:00 - 14:00 | 16:00 - 18:00',nil,false,nil,nil])
		end
		it '#list_schedules' do
			expect(org.timetable.list_schedules).to eq([nil, [sch4,sch3],[sch2,sch1],nil,false,nil,nil])
		end
	end
end