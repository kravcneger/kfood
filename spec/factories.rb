FactoryGirl.define do
	factory :organization do
		sequence(:name) {|n| "Organization #{n}" }
		sequence(:email) {|n| "example-#{n}@example.org" }
		password "foobarbar"
		password_confirmation "foobarbar"
	end

  factory :category do
    organization    
    name "Cat"
    category_id 0
    active false
    ordering 1
  end

  factory :addition do
    organization    
    name 'add1'
    addition_id 0
    price 10
    active false
  end

  factory :product do
    organization  
    category_id  Random.new.rand(1..3) 
    name "product#{Random.new.rand(1..100)}"
    price 0
    calories 0
    weight 0
    addition_id 0
    active 0
  end

  factory :schedule do
    organization  
    day 1
    is_holiday nil
    first_time nil
    second_time nil
  end

  factory :order do
    organization  
    name "name1"
    contact_phone "89500000001"
    street "street1"
    house '1'
    body 100
    price 100
    ip '127.0.0.1'
    delivery 100
  end


end