require 'spec_helper'

describe Product do
	let(:product){ Product.new }
	let(:org){ create(:organization) }

	let!(:org2){ create(:organization) }
	let!(:cat2){ create(:category, name: 'cat2', organization_id: org2.id) }
	let!(:add2){ create(:addition, name: 'add2', organization_id: org2.id) }

	subject { product }

	it{ should respond_to(:name)}
	it{ should respond_to(:description)}
	it{ should respond_to(:price)}
	it{ should respond_to(:weight)}
	it{ should respond_to(:calories)}
	it{ should respond_to(:active)}
	it{ should respond_to(:locked_to)}

	it{ should belong_to(:category) }
	it{ should belong_to(:addition) }
	it{ should belong_to(:organization) }

	it{ should validate_presence_of(:category_id) }	
	it{ should validate_presence_of(:organization_id) }
	it{ should validate_presence_of(:name) }	
	it{ should validate_presence_of(:price) }	
	
	describe "Relations" do
		let!(:product){ Product.new(name: 'prod1', category_id: cat2.id, organization_id: org.id, addition_id: add2.id) }

		it { expect(product.category).to eq(nil) }
		it { expect(product.addition).to eq(nil) }

		it do
			product.organization_id = org2.id
			expect(product.category).to eq(cat2)
			expect(product.addition).to eq(add2)
		end
	end

	describe "#status and available_to_order?" do
		let!(:pr1){ create(:product, organization_id: org2.id, category_id: cat2.id, active: 1) }
		let!(:pr2){ create(:product, organization_id: org2.id, category_id: cat2.id, active: 2, locked_to: (Time.now + 1.week) ) }
		let!(:pr3){ create(:product, organization_id: org2.id, category_id: cat2.id, active: 2, locked_to: (Time.now - 1.week) ) }
		let!(:pr4){ create(:product, organization_id: org2.id, category_id: cat2.id, active: 0) }
		it{ expect(pr1.status).to eq(1) }
		it{ expect(pr2.status).to eq(2) }
		it{ expect(pr3.status).to eq(1) }
		it{ expect(pr4.status).to eq(0) }

		it{ expect(pr1.available_to_order?).to eq(true) }
		it{ expect(pr2.available_to_order?).to eq(false) }
		it{ expect(pr4.available_to_order?).to eq(false) }
	end

	describe "load avatar" do
		it do
			file = File.new("#{Rails.root}/spec/fixtures/avatar.png")

			product.avatar = file
			product.save
			expect(product.errors[:avatar]).to eq([])
			expect(product.avatar?).to eq(true)
		end
	end

	describe "#check_category" do
		it do
			product.update_attributes(organization_id: org.id, category_id: cat2.id)
			expect(product.errors[:category_id]).to include('incorrect category')
		end
	end

	describe "#check_active" do
		it do
			product.update_attributes(organization_id: org.id, active: 2)
			expect(product.errors[:locked_to]).to include('can not be null')
		end
	end

	describe "#check_addition" do
		it 'incorrect' do
			product.update_attributes(organization_id: org.id, addition_id: add2.id)
			expect(product.errors[:addition_id]).to include('incorrect addition')
		end
		it 'is_sub' do
			sub_cat = create(:addition, name: 'add', organization_id: org2.id, addition_id: add2.id)
			product.update_attributes(organization_id: org2.id, addition_id: sub_cat.id)
			expect(product.errors[:addition_id]).to include('addition is sub')
		end
	end

end