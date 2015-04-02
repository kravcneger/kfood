require 'spec_helper'

describe Addition do
	let(:addition){ Addition.new }
	let(:org){ create(:organization) }

	subject { addition }

	it{ should respond_to(:name)}
	it{ should respond_to(:price)}

	it{ should have_many(:children) }
	it{ should belong_to(:parent) }
	it{ should belong_to(:organization) }

	it{ should validate_presence_of(:name) }	

	describe "set_active_for_children callback" do
		let!(:add1){ create(:addition, organization_id: org.id, active: true) }
		let!(:add1_1){ create(:addition, organization_id: org.id, addition_id: add1.id, active: true) }

		it{ expect(add1.children.where(active: true).count).to eq(1) }
		it do
			add1.update_attributes({active: false})
			expect(add1.children.where(active: true).count).to eq(0) 
			add1_1.update_attributes({active: true})
			expect(add1.children.where(active: true).count).to eq(0) 
			expect(org.additions.create(name: 'add...', addition_id: add1.id, active: true).active).to eq(false)
		end		

		it{ expect(org.additions.create(name: 'add1', addition_id: add1_1.id ).errors[:addition_id].any?).to eq(true) }

		it 'Move to nonexistent' do
			add1.update_attributes(addition_id: 9990)
			expect(add1.errors[:addition_id].any?).to eq(true)
		end

		it 'Move to itself' do
			add1.update_attributes(addition_id: add1.id)
			expect(add1.errors[:addition_id].any?).to eq(true)
		end
		it 'Move to sub_category' do
			add1.update_attributes(addition_id: add1_1.id)
			expect(add1.errors[:addition_id].any?).to eq(true)
		end

	end
end