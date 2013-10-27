require 'factory_girl'

FactoryGirl.define do

  factory :user do
    name 'User Josh'
    sequence :tel do |n|
      "#{n}7777777777"[0..9]
    end

    factory :coach do
      name 'Coach Josh'
    end
  end
end