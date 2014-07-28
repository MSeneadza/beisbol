require 'supermodel'

class BattingStat < SuperModel::Base
  include SuperModel::RandomID
  include SuperModel::Association

  attr_reader :player_id, :year, :league, :team_id, :games_played, :at_bats, :runs, :hits, :doubles, :triples,
              :home_runs, :rbi, :stolen_bases, :caught_stealing, :player


  def initialize(attributes = {})
    @player_id = attributes[:player_id]
    @year = attributes[:year]
    @league = attributes[:league]
    @team_id = attributes[:team_id]
    @at_bats = attributes[:at_bats].present? ? attributes[:at_bats] : 0
    @hits = attributes[:hits].present? ? attributes[:hits] : 0
    @home_runs = attributes[:home_runs].present? ? attributes[:home_runs] : 0
    @rbi = attributes[:rbi].present? ? attributes[:rbi] : 0
    @doubles = attributes[:doubles].present? ? attributes[:doubles] : 0
    @triples = attributes[:triples].present? ? attributes[:triples] : 0

  end

  def assign_player(player)

    @player = player

    player.add_batting_stat(self)
  end
end