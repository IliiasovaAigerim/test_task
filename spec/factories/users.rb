FactoryBot.define do
  factory :user do
    login { Faker::Internet.unique.email }
    password { "password" }
  end
end
