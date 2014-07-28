
require 'csv'

class Player


  #has_many :batting_stats

  #validates_presence_of :player_id

  attr_accessor :player_id, :batting_stats

  def initialize(atts = {})
    @player_id = atts[:player_id]
    @batting_stats = Array.new
  end

  def add_batting_stat(stat)
    @batting_stats << stat
  end

  def batting_average(the_year)
    stats = stats_for_year(the_year)
    hits = extract_stat(stats, :hits)
    at_bats = extract_stat(stats, :at_bats)
    hits.to_f / at_bats.to_f
  end

  def slugging_percentage(the_year)
    #Slugging percentage = ((Hits – doubles – triples – home runs) + (2 * doubles) + (3 * triples) + (4 * home runs)) / at-bats
    stats = stats_for_year(the_year)
    at_bats = extract_stat(stats, :at_bats)
    return 0 if at_bats == 0

    hits = extract_stat(stats, :hits)
    doubles = extract_stat(stats, :doubles)
    triples = extract_stat(stats, :triples)
    home_runs = extract_stat(stats, :home_runs)

    ((hits - doubles - triples - home_runs) + (2 * doubles) +
        (3 * triples) + (4 * home_runs)) / at_bats.to_f
  end

  def stats_for_year(the_year)
    @batting_stats.select {|bs| bs.year == the_year}
  end

  def num_at_bats(the_year)
    stats = stats_for_year(the_year)
    extract_stat(stats, :at_bats)
  end

  def num_home_runs(the_year)
    stats = stats_for_year(the_year)
    extract_stat(stats, :home_runs)
  end

  def num_rbi(the_year)
    stats = stats_for_year(the_year)
    extract_stat(stats, :rbi)
  end




  private

  def extract_stat(stats, stat_name)
    stats.inject(0) { |sum, stat| sum + stat.send(stat_name) }
  end

end

