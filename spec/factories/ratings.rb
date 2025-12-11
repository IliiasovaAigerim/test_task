FactoryBot.define do
  factory :rating do
    association :post
    association :user
  end
end
