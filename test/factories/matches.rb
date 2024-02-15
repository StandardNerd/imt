FactoryBot.define do
  factory :match do
    association :team
    name { "MyString" }
  end
end
