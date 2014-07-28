class HittingStatsReporter

  attr_reader :stats, :players

  def initialize
    @players = []
    @stats = []
  end

  def load_stats(csv_file)

    begin
      CSV.foreach("./data/#{csv_file}", headers: :first_row, header_converters: :symbol, converters: :numeric) do |row|
        attrs = Hash.new
        attrs[:player_id] = row[0]
        attrs[:year] = row[1]
        attrs[:league] = row[2]
        attrs[:team_id] = row[3]
        attrs[:at_bats] = row[5]
        attrs[:hits] = row[7]
        attrs[:home_runs] = row[10]
        attrs[:rbi]  = row[11]
        attrs[:doubles] = row[8]
        attrs[:triples] = row[9]

        new_stat = BattingStat.new( attrs )
        player = find_or_create_player(attrs)
        new_stat.assign_player(player)
        @stats << new_stat
      end
    rescue CSV::MalformedCSVError => e
      puts "Error while reading file: #{csv_file}: #{e} -- continuing..."
    end

  end

  def get_team_players(team_id, the_year)
    team_stats = @stats.select { |s| s.team_id == team_id }
    team_stats = team_stats.select{|s| s.year == the_year}

    team_stats.collect {|stat| stat.player}
  end


  def report_team_slugging(team_id, the_year)
    report = "***** Slugging Percentages for #{team_id} #{the_year} *****\n\n"
    team_players = get_team_players(team_id, the_year)
    team_players = team_players.sort {|a, b| a.full_name <=> b.full_name}
    team_players.each do |player|
      report << "#{player.full_name}: #{player.slugging_percentage(the_year).round(3)} \n"
    end
    report
  end

  def report_triple_crown_winners(the_year)
    report = "***** #{the_year} Triple Crown Winners *****\n\n"
    al_winners = find_triple_crown_winner('AL', the_year)
    report << "#{the_year} American League Triple Crown Winner(s):\n"

    if al_winners.count > 0
      al_winners.each {|p| report << "#{p.full_name} - Batting Average: #{p.batting_average(the_year).round(3)}, Home Runs: #{p.num_home_runs(the_year)}, RBI: #{p.num_rbi(the_year)}"}
    else
      report << "No winner\n"
    end

    nl_winners = find_triple_crown_winner('NL', the_year)

    report << "\n\n#{the_year} National League Triple Crown Winner:\n"

    if nl_winners.count > 0
      nl_winners.each {|p| report << "#{p.full_name} - Batting Average: #{p.batting_average(the_year).round(3)}, Home Runs: #{p.num_home_runs(the_year)}, RBI: #{p.num_rbi(the_year)}"}
    else
      report << "No winner\n"
    end
    report
  end

  def find_triple_crown_winner(league_id, the_year)
    league_stats = get_league_stats(league_id, the_year)
    league_players = league_stats.collect {|stat| stat.player}
    league_players = league_players.uniq

    eligible_players = filter_by_at_bats(league_players, 400, the_year)
    return [] unless eligible_players.count > 0

    top_batting_avg = sort_players_by_bat_avg(eligible_players, the_year).first.batting_average(the_year)
    top_bat_avg_players = get_players_by_batting_average(eligible_players,top_batting_avg, the_year)

    top_num_home_runs = sort_players_by_home_runs(eligible_players, the_year).first.num_home_runs(the_year)
    top_home_run_players = get_players_by_home_runs(eligible_players, top_num_home_runs, the_year)

    top_num_rbi = sort_players_by_rbi(eligible_players, the_year).first.num_rbi(the_year)
    top_rbi_players = get_players_by_rbi(eligible_players, top_num_rbi, the_year)

    find_common_members(top_bat_avg_players, top_home_run_players, top_rbi_players)
  end

  def report_most_improved_bat_avg(year1, year2)
    report = "***** Most Improved Batting Average from #{year1} to #{year2} *****\n\n"
    players_2009 = filter_by_at_bats(@players, 200, year1)

    players_2010 = filter_by_at_bats(@players, 200, year2)

    players_in_both_lists = players_2010 & players_2009

    sorted = players_in_both_lists.sort { |a, b| (b.batting_average(2010) - b.batting_average(2009)) <=> (a.batting_average(2010) - a.batting_average(2009)) }
    winning_difference = sorted.first.batting_average(2010) - sorted.first.batting_average(2009)
    report << "Winning Batting Average Increase is: #{ winning_difference}\n"

    winners = sorted.select { |p| p.batting_average(2010) - p.batting_average(2009) == winning_difference }

    report << "WINNER(S): \n"
    winners.each { |p| report << p.full_name }
    report
  end

  def get_league_stats(league_id, the_year)
    year_stats = stats.select {|s| s.year == the_year}
    year_stats.select {|s| s.league == league_id}
  end

  def filter_by_at_bats(players, min_number, the_year)
    players.select{|p| p.num_at_bats(the_year) >= min_number}
  end

  def sort_players_by_bat_avg(players, the_year)
    players.sort {|a, b| b.batting_average(the_year) <=> a.batting_average(the_year)}
  end

  def sort_players_by_home_runs(players, the_year)
    players.sort {|a, b| b.num_home_runs(the_year) <=> a.num_home_runs(the_year)}
  end

  def sort_players_by_rbi(players, the_year)
    players.sort {|a, b| b.num_rbi(the_year) <=> a.num_rbi(the_year)}
  end

  def find_common_members(arr1, arr2, arr3)
    arr1 & arr2 & arr3
  end

  def get_players_by_rbi(players, num_rbi, the_year)
     players.select{|p| p.num_rbi(the_year) == num_rbi}
  end

  def get_players_by_home_runs(players, num_hrs, the_year)
    players.select{|p| p.num_home_runs(the_year) == num_hrs}
  end

  def get_players_by_batting_average(players, bat_avg, the_year)
    players.select{|p| p.batting_average(the_year) == bat_avg}
  end

  def find_or_create_player(attrs)
    matching_player = @players.select{|p| p.player_id == attrs[:player_id]}.first
    if matching_player
      matching_player
    else
      @players << Player.new(attrs)
      @players.last
    end


  end
end