require 'factory_girl'

FactoryGirl.define do

  factory :post do
    text 'message'
    
    trait :show_epic_details do
      intent Post::Intents[:coach][:showed_epic_details]
    end
  end
end