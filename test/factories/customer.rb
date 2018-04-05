FactoryBot.define do
  factory :customer do
    name 'Customer'
    router_id { create(:router).id }
    profile_id { create(:profile).id }
    reseller_id { create(:reseller).id }
    max_plannings 10
    max_zonings 15
    max_destinations 66
    max_vehicle_usage_sets 5
    max_vehicles 10

    factory :customer_with_vehicles do
      after(:create) do |customer, evaluator|
        [1..4].each do |_i|
          puts "Create vehicle"
          create(:vehicle, customer_id: customer.id)
        end
      end
    end
  end
end
