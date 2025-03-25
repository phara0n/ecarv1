FactoryBot.define do
  factory :vehicle do
    customer { nil }
    brand { "MyString" }
    model { "MyString" }
    year { 1 }
    license_plate { "MyString" }
    vin { "MyString" }
    current_mileage { 1 }
    average_daily_usage { 1.5 }
  end
end
