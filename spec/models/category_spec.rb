require 'spec_helper'

describe Category do
	let(:category){ Category.new }
	let(:org1){ create(:organization) }
	let(:org2){ create(:organization) }

	let!(:cat1){ org1.categories.create!(name: 'cat1') }
	let!(:cat1_1){ org1.categories.create!(name: 'cat1_1', category_id: cat1.id) }
	let!(:org2_cat1){ org2.categories.create!(name: 'org2_cat1') }
	let!(:cat1_2){ org1.categories.create!(name: 'cat1_2', category_id: cat1.id) }
	let!(:cat1_3){ org1.categories.create!(name: 'cat1_3', category_id: cat1.id) }
	let!(:cat2){ org1.categories.create!(name: 'cat2') }

	subject { category }

	it{ should respond_to(:name)}
	it{ should respond_to(:ordering)}

	it{ should have_many(:children) }
	it{ should have_many(:products) }
	it{ should have_many(:products_all) }
	it{ should belong_to(:parent) }

	it{ should validate_presence_of(:name) }
	it{ should validate_presence_of(:organization_id) }

	it{ expect(category.after_category).to eq(nil) }

	describe "ordering" do
		it{ expect(org2_cat1.ordering).to eq(0) }
		it{ expect(cat1_2.ordering).to eq(1) }
		it{ expect(cat1.ordering).to eq(0) }
		it{ expect(cat2.ordering).to eq(1) }
		it do
			cat0 = org1.categories.create(name: 'catt', after_category: cat1)
			expect(cat1.reload.ordering).to eq(0)
			expect(cat0.ordering).to eq(1)
			expect(cat2.reload.ordering).to eq(2)

			cat1_1.update({after_category: cat1_2})

			expect(cat1_1.reload.ordering).to eq(1)
			expect(cat1_2.reload.ordering).to eq(0)
			expect(cat1_3.reload.ordering).to eq(2)
		end
		it 'insert in beginning list' do
			cat1_0 = org1.categories.create(name: 'catt', category_id: cat1.id, after_category: -1)
			expect(cat1_1.reload.ordering).to eq(1)
			expect(cat1_0.ordering).to eq(0)	

			cat1_3.update({after_category: -1})

			expect(cat1_3.reload.ordering).to eq(0)	
			expect(cat1_1.reload.ordering).to eq(2)
			expect(cat1_0.reload.ordering).to eq(1)			
		end
	end

	describe "#is_sub?" do
		it{ expect(cat1.is_sub?).to eq(false) }
		it{ expect(cat1_2.is_sub?).to eq(true) }
	end

	describe "#get_brothers" do
		it{ expect(cat1.get_brothers).to eq([cat2]) }
		it{ expect(cat1_2.get_brothers).to eq([cat1_1, cat1_3]) }
		it{ expect(Category.new(organization_id: org2.id, category_id: 0).get_brothers).to eq([org2_cat1]) }
	end

	describe "Move" do
		it{ expect(org1.categories.create(name: 'cat3', category_id: cat1_1.id ).errors[:category_id].any?).to eq(true) }

		it 'to nonexistent' do
			cat1.update_attributes(category_id: 9990)
			expect(cat1.errors[:category_id].any?).to eq(true)
		end

		it 'to itself' do
			cat1.update_attributes(category_id: cat1.id)
			expect(cat1.errors[:category_id].any?).to eq(true)
		end

		it 'to sub_category' do
			cat1.update_attributes(category_id: cat1_2.id)
			expect(cat1.errors[:category_id].any?).to eq(true)
		end
	end

	describe "set_active_for_children callback" do
		it{ expect(cat1.children.where(active: true).count).to eq(3) }
		it do
			cat1.update_attributes({active: false})
			expect(cat1.children.where(active: true).count).to eq(0) 
			expect(org1.categories.create(name: 'cat...', category_id: cat1.id, active: true).active).to eq(false)
		end
	end
end
