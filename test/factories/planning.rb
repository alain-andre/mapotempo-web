FactoryBot.define do
  factory :planning do
    name 'test'
    customer_id { create(:customer_with_vehicles).id }
    ref { "#ref#{Random.rand(20)}" }
    date { 1.month.ago }
    vehicle_usage_set_id { create(:vehicle_usage_set).id }

    after(:create) do |planning|
      planning.default_routes
      planning.compute
    end
  end
end
