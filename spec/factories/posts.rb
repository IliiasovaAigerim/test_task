FactoryBot.define do
  factory :post do
    title { "MyString" }
    body { "MyText" }
    user { nil }
    ip { "MyString" }
  end
end
