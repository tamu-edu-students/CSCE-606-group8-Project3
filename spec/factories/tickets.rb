FactoryBot.define do
  factory :ticket do
    subject { "MyString" }
    description { "MyText" }
    status { 1 }
    priority { 1 }
    requester { nil }
    assignee { nil }
    category { "MyString" }
    closed_at { "2025-10-20 10:23:41" }
  end
end
