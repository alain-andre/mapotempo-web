FactoryBot.define do
  factory :vehicle_usage_set do
    customer_id { create(:customer).id }
    name 'customer'
    open '10:00:00'
    close '15:00:00'
  end
end
