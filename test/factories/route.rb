FactoryBot.define do
  factory :route do
    planning_id { create(:planning).id }
    lock_version 0
  end
end
