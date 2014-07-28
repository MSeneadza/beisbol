require 'rspec'
require 'spec_helper'
require 'factory_girl'

describe Player do

  it 'has a valid factory' do

    #expect(build(:player)).to be_valid
  end

  it 'has many batting_stats' do
    p = Player.new
    expect(p).to respond_to(:batting_stats)
  end

  it 'can find its stats for a given year' do
    p = Player.new
    stat1 = BattingStat.new({year: 2007, hits: 30, at_bats: 200})
    stat2 = BattingStat.new({year: 2008, hits: 30, at_bats: 200})
    stat3 = BattingStat.new({year: 2009, hits: 30, at_bats: 200})
    p.add_batting_stat(stat1)
    p.add_batting_stat(stat2)
    p.add_batting_stat(stat3)

    expect(p.stats_for_year(2007).first).to eq(stat1)
  end

  it 'can calculate its batting average for a given year' do
    #p = build(:player)
    p = Player.new
    stat = {year: 2007, hits: 30, at_bats: 200}
        #hit / at-bats
    p.add_batting_stat(BattingStat.new(stat))
    correct_average = 30.to_f / 200.to_f
    expect(p.batting_average(2007)).to eq(correct_average)
  end

  it 'knows its number of at-bats for a given year' do
    p = Player.new
    stat1 = BattingStat.new({year: 2007, hits: 30, at_bats: 130})
    stat2 = BattingStat.new({year: 2007, hits: 13, at_bats: 50})
    stat3 = BattingStat.new({year: 2008, hits: 30, at_bats: 200})
    p.add_batting_stat(stat1)
    p.add_batting_stat(stat2)
    p.add_batting_stat(stat3)

    expect(p.num_at_bats(2007)).to eq(180)
  end

  it 'knows its number of home runs for a given year' do
    p = Player.new
    stat1 = BattingStat.new({year: 2007, hits: 30, at_bats: 130, home_runs: 25})
    stat2 = BattingStat.new({year: 2007, hits: 13, at_bats: 50, home_runs: 20})
    stat3 = BattingStat.new({year: 2008, hits: 30, at_bats: 200, home_runs: 25})
    p.add_batting_stat(stat1)
    p.add_batting_stat(stat2)
    p.add_batting_stat(stat3)

    expect(p.num_home_runs(2007)).to eq(45)
  end

  it 'knows its number of RBI for a given year' do
    p = Player.new
    stat1 = BattingStat.new({year: 2007, hits: 30, at_bats: 130, rbi: 25})
    stat2 = BattingStat.new({year: 2007, hits: 13, at_bats: 50, rbi: 50})
    stat3 = BattingStat.new({year: 2008, hits: 30, at_bats: 200, rbi: 25})
    p.add_batting_stat(stat1)
    p.add_batting_stat(stat2)
    p.add_batting_stat(stat3)

    expect(p.num_rbi(2007)).to eq(75)
  end

  it 'knows its slugging percentage for a given year' do
    # Slugging percentage =
    # ((Hits – doubles – triples – home runs) + (2 * doubles) + (3 * triples) + (4 * home runs)) / at-bats

    p = Player.new
    stat1 = BattingStat.new({year: 2007, hits: 30, at_bats: 450, rbi: 25, doubles: 10, triples: 5, home_runs: 14})
    p.add_batting_stat(stat1)

    the_answer = ((stat1.hits - stat1.doubles - stat1.triples - stat1.home_runs) + (2 * stat1.doubles) +
        (3 * stat1.triples) + (4 * stat1.home_runs)) / stat1.at_bats.to_f

    expect(p.slugging_percentage(2007)).to eq(the_answer)
  end

  it 'knows its slugging percentage for a given year if it was traded mid-season' do
    # Slugging percentage =
    # ((Hits – doubles – triples – home runs) + (2 * doubles) + (3 * triples) + (4 * home runs)) / at-bats

    p = Player.new
    stat1 = BattingStat.new({year: 2007, hits: 20, at_bats: 250, rbi: 25, doubles: 10, triples: 5, home_runs: 14})
    stat2 = BattingStat.new({year: 2007, hits: 30, at_bats: 209, rbi: 15, doubles: 4, triples: 2, home_runs: 9})
    p.add_batting_stat(stat1)
    p.add_batting_stat(stat2)

    the_answer = ((50 - 14 - 7 - 23) + (2 * 14) + (3 * 7) + (4 * 23)) / 459.to_f

    expect(p.slugging_percentage(2007)).to eq(the_answer)
  end



  it 'does not divide by zero' do
    #pass in at_bats = 0
    #should return zero
  end

  it 'should find player names in the csv player file given a player_id' do
    name = 'ariasal02'
    player_name = Player.get_player_name(name)
    expect(player_name).to eq('Alberto Arias')

  end


end