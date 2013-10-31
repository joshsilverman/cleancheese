require 'factory_girl'

FactoryGirl.define do

  factory :coach do
    name 'Coach Josh'
    sequence :tel do |n|
      "#{n}7777777777"[0..9]
    end
  end
end