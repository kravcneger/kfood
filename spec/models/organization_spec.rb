require 'spec_helper'

describe Organization do
	let(:organization){ Organization.new }
	subject { organization }

	it{ should respond_to(:name)}
	it{ should respond_to(:description)}
	it{ should respond_to(:min_delivery)}
	it{ should respond_to(:delivery)}
	it{ should respond_to(:free_shipping)}
	it{ should respond_to(:active)}
	it{ should respond_to(:email)}
	it{ should respond_to(:password)}
  it{ should respond_to(:map_code)}

  it{ should have_many(:categories) }
  it{ should have_many(:categories_all) }

  it{ should have_many(:additions) }
  it{ should have_many(:additions_all) }

  #it{ should have_many(:products) }
  #it{ should have_many(:addtions) }
  #it{ should have_many(:schedules) }

  it{ should validate_presence_of(:name) }
  it{ should validate_presence_of(:email) }
  it{ should validate_presence_of(:password) }


  describe "#get_menu" do
  	let(:org){ create(:organization) }
  	let!(:cat1){ create(:category, name: 'c_1', organization_id: org.id) }
  	let!(:cat2){ create(:category, name: 'c_2',organization_id: org.id, after_category: -1) }
  	let!(:cat1_1){ create(:category, name: 'c_1_1',organization_id: org.id, category_id: cat2.id) }
  	let!(:cat1_2){ create(:category, name: 'c_1_2',organization_id: org.id, after_category: -1, category_id: cat2.id, active: true) }
  	let!(:cat1_3){ create(:category, name: 'c_1_3',organization_id: org.id, after_category: -1, category_id: cat2.id) }
  	let!(:cat4){ create(:category, name: 'c_4',organization_id: org.id, active: true) }
  	let!(:cat4_1){ create(:category, name: 'c_4_1',organization_id: org.id,category_id: cat4.id, active: true) }

  	it { expect(org.get_menu).to eq({ 6=> { item: cat4, children: [cat4_1] } }) }

  	it { expect(org.get_menu(:all)).to eq(
  		{  			
  			2=> { item: cat2, children: [cat1_3,cat1_2,cat1_1] },
  			1=> { item: cat1, children: [] },
  			6=> { item: cat4, children: [cat4_1] },
  			}) }

  end

  describe "#get_additions" do
    let(:org){ create(:organization) }
    let!(:add1){ create(:addition, name: 'abdd', organization_id: org.id) }
    let!(:add2){ create(:addition, name: 'aadd', organization_id: org.id) }
    let!(:add2_1){ create(:addition, name: 'add2_1', organization_id: org.id, addition_id: add2.id ) }
    let!(:add1_1){ create(:addition, name: 'add1_1', organization_id: org.id, addition_id: add1.id ) }

    it { expect(org.get_additions(:all)).to eq(
      {  			
       2=> { item: add2, children: [add2_1] },
       1=> { item: add1, children: [add1_1] },
       }) }  	
  end

  describe "#map_code" do
    it do
      organization.map_code = '<script src="vices/js/?si=asa&id=mymap"></script>'
      organization.valid?
      expect(organization.errors[:map_code].count).to eq(1)
      organization.map_code = '<script src="vices/js/?sid=asa&id=mymap"></script>'
      organization.valid?
      expect(organization.errors[:map_code].count).to eq(0)
    end   
  end

  describe "Update" do
    let(:org){ create(:organization, password: '222222222', password_confirmation: '222222222') }
    
    context 'Password' do
      it 'when current password is not specified' do
        org.update({password: '12345678', password_confirmation: '12345678'})
        expect(org.errors[:current_password].count).to eq(1)
      end
      it 'when current password is specified' do
        org.update({password: '12345678', password_confirmation: '12345678', current_password: '222222222'})
        expect(org.errors[:current_password].count).to eq(0)
      end 
    end

    context 'Email' do
      it 'when current password is not specified' do
        org.update({email: 'email@email.ru', current_password: '222222221'})
        expect(org.errors[:current_password].count).to eq(1)
      end
      it 'when current password is specified' do
        org.update({email: 'email@email.ru', current_password: '222222222'})
        expect(org.errors[:current_password].count).to eq(0)
      end 
    end

  end


end
