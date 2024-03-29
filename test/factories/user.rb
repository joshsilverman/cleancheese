require 'factory_girl'

FactoryGirl.define do

  factory :user do
    name 'User Josh'
    sequence :tel do |n|
      "#{n}8888888888"[0..9]
    end
  end
end