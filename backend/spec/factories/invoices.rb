FactoryBot.define do
  factory :invoice do
    repair { nil }
    amount { "9.99" }
    payment_status { "MyString" }
    pdf_document { "MyString" }
    vat_amount { "9.99" }
    payment_method { "MyString" }
  end
end
