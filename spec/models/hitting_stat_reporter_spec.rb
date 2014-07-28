require 'rspec'
require 'spec_helper'
require 'factory_girl'

describe HittingStatsReporter do

  it 'should load hitting stats data from am input CSV file' do
    reporter = HittingStatsReporter.new
    reporter.load_stats('Test-Batting.csv')

    expect(reporter.stats.count).to equal(354)
  end

  it 'should have a list of players' do
    reporter = HittingStatsReporter.new
    expect(reporter).to respond_to(:players)
  end

  it 'should create players with stats attached' do
    reporter = HittingStatsReporter.new
    reporter.load_stats('Test-Batting.csv')

    expect(reporter.players.last.batting_stats).to be_present
  end

  it 'should not create duplicate players' do
    reporter = HittingStatsReporter.new

    attrs1 = {player_id: 'Player_1'}
    attrs2 = {player_id: 'Player_1'}
    attrs3 = {player_id: 'Player_2'}

    reporter.find_or_create_player(attrs1)
    reporter.find_or_create_player(attrs2)
    reporter.find_or_create_player(attrs3)

    expect(reporter.players.count).to eq(2)
    expect(reporter.players.first.player_id).to_not eq(reporter.players.last.player_id)
  end

  it 'should be able to filter the list of players by team and year' do
    reporter = HittingStatsReporter.new
    reporter.load_stats('Test-Batting.csv')

    team_players = reporter.get_team_players('PIT', 2012)
    #based on the test file there are 2 PIT player for 2012 - barajro01 and alvarpe01

    expect(team_players.count).to eq(2)

    expected_players = team_players.select{|p| p.player_id == 'barajro01'}
    expect(expected_players.count).to eq(1)

    expected_players2 = team_players.select{|p| p.player_id == 'alvarpe01'}
    expect(expected_players2.count).to eq(1)
  end

  it 'should report the slugging percentages for all players on a given team and year' do
    reporter = HittingStatsReporter.new
    reporter.load_stats('Test-Batting.csv')

    report = reporter.report_team_slugging('PIT', 2012)
    expect(report.index('Pedro Alvarez: 0.467')).not_to be_nil
  end

  it 'should filter all stats for a league and year' do
    reporter = HittingStatsReporter.new
    reporter.load_stats('Test-Batting.csv')

    league_stats = reporter.get_league_stats('AL', 2012)
    expect(league_stats.count).to eq(36)
  end

  it 'should filter a list of players by a minimum number of at-bats' do
    reporter = HittingStatsReporter.new
    reporter.load_stats('Test-Batting.csv')

    team_players = reporter.get_team_players('BAL', 2011)

    filtered_list = reporter.filter_by_at_bats(team_players, 80, 2011)
    expect(filtered_list.count).to eq(2)
  end

  it 'should sort a list of players by batting average for a given year DESC' do
    reporter = HittingStatsReporter.new
    reporter.load_stats('Test-Batting.csv')

    filtered_list = reporter.filter_by_at_bats(reporter.players, HittingStatsReporter::TRIPLE_CROWN_AB_THRESHOLD, 2011)
    sorted_list = reporter.sort_players_by_bat_avg(filtered_list, 2011)
    expect(sorted_list.first.player_id).to eq('avilaal01')
  end

  it 'should sort a list of players by num home runs for a given year DESC' do
    reporter = HittingStatsReporter.new
    reporter.load_stats('Test-Batting.csv')

    filtered_list = reporter.filter_by_at_bats(reporter.players, HittingStatsReporter::TRIPLE_CROWN_AB_THRESHOLD, 2011)
    sorted_list = reporter.sort_players_by_home_runs(filtered_list, 2011)
    expect(sorted_list.first.player_id).to eq('arencjp01')
  end

  it 'should sort a list of players by runs-batted-in for a given year DESC' do
    reporter = HittingStatsReporter.new
    reporter.load_stats('Test-Batting.csv')

    filtered_list = reporter.filter_by_at_bats(reporter.players, HittingStatsReporter::TRIPLE_CROWN_AB_THRESHOLD, 2011)
    sorted_list = reporter.sort_players_by_rbi(filtered_list, 2011)
    expect(sorted_list.first.player_id).to eq('avilaal01')
  end

  it 'should be able to find the common members of three arrays' do
    arr1 = [22, 33, 44]
    arr2 = [33, 66, 99]
    arr3 = [32, 33, 34]

    reporter = HittingStatsReporter.new
    common_members = reporter.find_common_members(arr1, arr2, arr3)
    expect(common_members.count).to eq(1)
    expect(common_members[0]).to eq(33)

  end

  it 'should extract players with a specific rbi count for a year' do
    reporter = HittingStatsReporter.new
    reporter.load_stats('Test-Batting.csv')
    year = 2011
    filtered_list = reporter.get_players_by_rbi(reporter.players, 60, year)
    expect(filtered_list.count).to eq(2)
    player = filtered_list.first
    expect(player.num_rbi(year)).to eq(60)
  end

  it 'should extract players with a specific home run count for a year' do
    reporter = HittingStatsReporter.new
    reporter.load_stats('Test-Batting.csv')
    year = 2011
    filtered_list = reporter.get_players_by_home_runs(reporter.players, 5, year)
    expect(filtered_list.count).to eq(3)
    player = filtered_list.first
    expect(player.num_home_runs(year)).to eq(5)
  end

  it 'should extract players with a specific batting average for a year' do
    reporter = HittingStatsReporter.new
    reporter.load_stats('Test-Batting.csv')
    year = 2011
    filtered_list = reporter.get_players_by_batting_average(reporter.players, 0.25, year)
    expect(filtered_list.count).to eq(1)
    player = filtered_list.first
    expect(player.batting_average(year)).to eq(0.25)
  end

  it 'should report Triple Crown Winners' do
    reporter = HittingStatsReporter.new
    #reporter.load_stats('Test-Batting.csv')
    #no eligible players in the small test file so I'm using the real file for now
    #TODO: setup some data with a winner so I can stop using the full data file here
    reporter.load_stats('Batting-07-12.csv')

    output = reporter.report_triple_crown_winners(2012)
    expect(output.index('Miguel Cabrera')).to_not be_nil
  end

  it 'should report the player(s) with the most improved batting average' do
    reporter = HittingStatsReporter.new
    reporter.load_stats('Test-Batting.csv')

    output = reporter.report_most_improved_bat_avg(2009, 2010)
    expect(output.index('Rod Barajas')).to_not be_nil
  end
end