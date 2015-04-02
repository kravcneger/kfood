namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do    
    make_organizations
    make_categories
    make_additions
  end

  task clear: :environment do 
    clear_tables
  end
end

def make_organizations
  Organization.connection.execute('ALTER SEQUENCE organizations_id_seq RESTART WITH 1;')
  10.times do |n|
    name  = Faker::Name.name
    email = "example-#{n+1}@example.org"
    password  = "password"
    Organization.create!(
      id: n+1,
      name:     name,
      email:    email,
      password: password,
      map_code: '?sid=csTo9R0J0U63GSjeaX650UFp10lf44aR&',
      published: true,
      password_confirmation: password)
  end
end

def make_categories
  Organization.all.each do |organization|
    10.times do |n|
      organization.categories.create!(name: ['Rolli','Susi magu','Herolli','Zakuski','Salates'][ rand(5)], active: true)
    end
  end
  
  first_org = Organization.first
  first_org.categories_all[6..-1].each do |cat|
    3.times do |n|
      cat.children.create!(name: ['Cat1','cat2'][ rand(2)], organization_id: first_org.id, active: [true,false][ rand(2)])
    end
    12.times do |n|
      make_products(first_org, cat.id)
    end
  end
end

def make_additions
  adds = ['add1','add2','soli','perec','sahar','vasabi','sous']

  Organization.all[0..1].each do |org|
    org.additions.create!(name: 'Picci', active: true)
    org.additions.create!(name: 'Zakuski', active: true)
    org.additions.create!(name: 'Rolli', active: true)
  end  

  Addition.all.each do |addition|
    14.times do |i|
     addition.children.create!(name: adds[rand(adds.size)], active: [true,true,false][rand(3)], organization_id: addition.organization_id, price: 20 )
   end
 end
end

def make_products(org, category_id)
  file = File.new("#{Rails.root}/spec/fixtures/images_kfood/#{rand(1..5)}.jpg")
  org.products.create!(name: ['Роллы калифорния','Суси суп','Роллы самурай','Венгрескийся сала'][rand(3)], category_id: category_id, active: 1, price: rand(300), description: 'Лосось, огруец, помидоры, сыр, купаста', weight: 300, avatar: file )
end

def clear_tables
  Organization.destroy_all
  Category.destroy_all
  Product.destroy_all
  Addition.destroy_all
  Schedule.destroy_all
  Order.destroy_all
end