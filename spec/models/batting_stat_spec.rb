require 'rspec'
require 'spec_helper'
require 'factory_girl'

describe BattingStat do

  it 'has a valid factory' do

    expect(build(:batting_stat)).to be_valid
  end

  # it 'assigns a player when created' do
  #   stat1 = BattingStat.new({player_id: 'Player1', year: 2007, hits: 30, at_bats: 130, rbi: 25})
  #   p = stat1.player
  #
  #   expect(p.player_id).to eq('Player1')
  # end

  it 'registers itself with the player' do
    player = Player.new({player_id: 'Player1'})
    stat1 = BattingStat.new({player_id: 'Player1', year: 2007, hits: 30, at_bats: 130, rbi: 25})
    stat1.assign_player(player)

    expect(player.stats_for_year(2007).first).to eq(stat1)
  end
end