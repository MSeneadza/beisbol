require 'factory_girl'
require 'batting_stat'

FactoryGirl.define do
  factory :batting_stat do

    sequence(:player_id) {|n| "Player_#{n}"}
    year 2010

    initialize_with { new(attributes) }
  end
end
