
require_relative 'lib/hitting_stats_reporter'
require 'csv'
require_relative 'lib/batting_stat'
require_relative 'lib/player'

reporter = HittingStatsReporter.new

reporter.load_stats('Batting-07-12.csv')

puts reporter.report_most_improved_bat_avg(2009, 2010)

puts "\n\n\n"
puts reporter.report_team_slugging('OAK', 2007)

puts "\n\n\n"
puts reporter.report_triple_crown_winners(2012)

#reporter = PitchingStatsReporter.new
#reporter.load_stats('Pitching-Data.csv')
#calls to create pitching report

