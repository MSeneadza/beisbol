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
    @at_bats = attributes[:at_bats]
    @hits = attributes[:hits]
    @home_runs = attributes[:home_runs]
    @rbi = attributes[:rbi]
    @doubles = attributes[:doubles]
    @triples = attributes[:triples]

    #assign_player(@player_id)
  end

  def assign_player(player)
    #p = Player.new
    #p.player_id = player_id
    @player = player

    player.add_batting_stat(self)
  end
end