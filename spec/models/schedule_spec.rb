require 'spec_helper'

describe Schedule do
	let(:schedule){ Schedule.new }
	let(:org){ create(:organization) }

	subject { schedule }

	it{ should respond_to(:day)}
	it{ should respond_to(:is_holiday)}
	it{ should respond_to(:first_time)}
	it{ should respond_to(:second_time)}

	it{ should belong_to(:organization) }

	it{ should validate_presence_of(:day) }	

	it 'Check day' do
		schedule.update({day: 8})
		expect(schedule.errors[:day].count).to eq(1) 
		schedule.update({day: 6})
		expect(schedule.errors[:day].count).to eq(0) 
	end

	it 'Check is holiday' do
		schedule.update({is_holiday: false})
		expect(schedule.errors[:is_holiday].count).to eq(1) 
		schedule.update({is_holiday: 1})
		expect(schedule.errors[:is_holiday].count).to eq(0)
		schedule.update({is_holiday: true})
		expect(schedule.errors[:is_holiday].count).to eq(0) 
	end

	it 'Check format to time' do		
		schedule.update({first_time: '25:00'})
		expect(schedule.errors[:first_time].count).to eq(1) 
		schedule.update({first_time: '10:10'})
		expect(schedule.errors[:first_time].count).to eq(0) 	

		schedule.update_attributes(first_time: '10:10', second_time: '10:08')
		expect(schedule.errors[:first_time]).to include('First time must be less than second_time')
	end

	it 'Check rules for crossing' do
    sch1 = create(:schedule, organization_id: org.id, day: 1, first_time: '14:00', second_time: '15:00')
    sch2 = create(:schedule, organization_id: org.id, day: 1, first_time: '10:00', second_time: '12:00')

    sch2.update({second_time: '14:10'})
    expect(sch2.errors[:base]).to include('Time rangers should not overlap')

    sch2.update({second_time: '13:00'})
    expect(sch2.errors[:base]).not_to include('Time rangers should not overlap')

    sch1.update({first_time: '13:00'})
    expect(sch1.errors[:base]).to include('Time rangers should not overlap')

    sch1.update({first_time: '09:00', second_time: '16:00' })
    expect(sch1.errors[:base]).to include('Time rangers should not overlap')    
    # Устанваливаем выходной день
    # sch2.update({day: 1, is_holiday: true, first_time: '11:10'})
    # expect(sch2.errors[:base]).not_to include('Time rangers should not overlap')
	end
end