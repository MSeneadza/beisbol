require 'factory_girl'
require 'player'

FactoryGirl.define do
  factory :player do
    sequence(:player_id) {|n| "Player_#{n}"}
    #name { "something" }

  end
end
