FactoryBot.define do
  factory :user do
    email { "e#{Random.rand(20)}@m#{%w[a b c d e][Random.rand(5)]}il.fr" }
    password '123456789'
    api_key 'api_key'
    layer { create(:layer) }
    confirmed_at { 1.week.ago }
    confirmation_token { User.new.generate_confirmation_token }
    time_zone 'UTC'
    prefered_unit 'km'
    customer_id { create(:customer).id }
  end
end
