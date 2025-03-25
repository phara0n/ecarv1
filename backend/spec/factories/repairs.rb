FactoryBot.define do
  factory :repair do
    vehicle { nil }
    description { "MyText" }
    start_date { "2025-03-25" }
    completion_date { "2025-03-25" }
    cost { "9.99" }
    status { "MyString" }
    mechanic { "MyString" }
    parts_used { "MyText" }
    labor_hours { 1.5 }
    next_service_estimate { "2025-03-25" }
  end
end
