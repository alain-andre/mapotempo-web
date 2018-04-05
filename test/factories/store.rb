FactoryBot.define do
  factory :store do
    ref { "#a#{Random.rand(20)}" }
    name { "#a#{Random.rand(20)}" }
    lat 1.5
    lng 1.5
    customer_id { create(:customer).id }
  end
end
