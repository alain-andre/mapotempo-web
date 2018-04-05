FactoryBot.define do
  factory :vehicle_usage do
    # customer = create(:customer)
    # puts customer
    # store = create(:store, customer_id: customer)

    customer_id { customer.id }
    vehicle_usage_set { create(:vehicle_usage_set_one, customer_id: customer.id) }
    vehicle { create(:vehicle, customer_id: customer.id) }
    store_start { store }
    store_stop { store }
  end
end
