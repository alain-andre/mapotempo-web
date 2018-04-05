FactoryBot.define do
  factory :vehicle do
    name { "Vehicle-#{Random.rand(20)}" }
    customer_id { create(:customer).id }

    before(:create) do |vehicle, evaluator|
      puts vehicle
    end
  end
end
