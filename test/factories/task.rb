require 'factory_girl'

FactoryGirl.define do

  factory :task do
    name 'Do this!'

    trait :complete do
      complete true
    end
  end
end