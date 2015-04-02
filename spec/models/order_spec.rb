require 'spec_helper'

describe Order do
	let(:order){ Order.new }
	let(:org){ create(:organization) }

	subject { order}

	it{ should belong_to(:organization) }

	it{ should respond_to(:name)}
	it{ should respond_to(:street)}
	it{ should respond_to(:house)}
	it{ should respond_to(:contact_phone)}
	it{ should respond_to(:addition_info)}
  it{ should respond_to(:time_order)}
 
	it{ should respond_to(:comment)}
	it{ should respond_to(:body)}
	it{ should respond_to(:status)}
	it{ should respond_to(:price)}
	it{ should respond_to(:delivery)}

	it{ should validate_presence_of(:name) }	
	it{ should validate_presence_of(:street) }	
	it{ should validate_presence_of(:house) }	
	it{ should validate_presence_of(:contact_phone) }	

	it{ should validate_presence_of(:body) }	
	it{ should validate_presence_of(:price) }
	it{ should validate_presence_of(:delivery) }

  it "check phone" do
    order.update({contact_phone: nil})
    expect(order.errors[:contact_phone].count).not_to eq(0)

    order.update({contact_phone: 1234})
    expect(order.errors[:contact_phone].count).not_to eq(0)   

    order.update({contact_phone: 89508273270})
    expect(order.errors[:contact_phone].count).to eq(0)
  end

  it "check body" do
    order.update({body: nil})
    expect(order.errors[:body].count).not_to eq(0)
    
    expect{order.update({body: 'sad;/asd23;)-'})}.to raise_error(MultiJson::ParseError)

    order.update({body: {name: 34, Fedia: {Piter: 6} }})
    expect(order.errors[:body].count).to eq(0)   

    order.update({body: '{"name": {"ble": 2} }'})
    expect(order.errors[:body].count).to eq(0)
  end

  it "Save" do
     order.organization_id = org.id
     order.name = 'Fedor'
     order.contact_phone = 89508273270
     order.street = 'Kirova'
     order.house = '7a'
     order.apartment = 34
     order.body = {day: 5}
     order.price = 120
     order.delivery = 0
     order.save
     expect(order.errors.count).to eq(0)
     expect(order.body[:day]).to eq(5)
     expect(order.addition_info[:apartment]).to eq(34)
  end

end