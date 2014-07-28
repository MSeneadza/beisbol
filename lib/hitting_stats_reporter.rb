class HittingStatsReporter

  attr_reader :stats, :players

  def initialize
    @players = []
    @stats = []
  end

  def load_stats(csv_file)
    #csv_file = 'Batting-07-12.csv'
    # quote_chars = %w(" | ~ ^ & *)
    # begin
    #   @report = CSV.read(csv_file, headers: :first_row, quote_char: quote_chars.shift)
    # rescue CSV::MalformedCSVError => e
    #   #reject(io.lineno, the_line, e.to_s)
    # end

    begin
      CSV.foreach("./data/#{csv_file}", headers: :first_row, header_converters: :symbol, converters: :numeric) do |row|
        #puts row
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
      puts "Error while reading file: #{csv_file}: #{e}"
    end


    puts "number of rows read = #{@stats.count}"
    puts "number of Players created = #{@players.count}"
    puts @stats.last.inspect
    #<Player:0x007fe4e6d928f8 @new_record=false, @attributes={"playerID"=>"zumayjo01", "yearID"=>"2008", "league"=>"AL", "teamID"=>"DET", "G"=>"21", "AB"=>"0", "R"=>"0", "H"=>"0", "2B"=>"0", "3B"=>"0", "HR"=>"0", "RBI"=>"0", "SB"=>"0", "CS"=>"0", "id"=>"12e6894286de29b09059920703"}, @changed_attributes={}>

    #@players.each {|p| puts p.inspect}

    #calc_most_improved_bat_avg


    #oak_players = Player.find_all_by_teamID('OAK')
    #oak_players.each {|op| puts op.playerID}
  end

  def get_team_players(team_id, the_year)
    team_stats = @stats.select { |s| s.team_id == team_id }
    team_stats = team_stats.select{|s| s.year == the_year}

    team_stats.collect {|stat| stat.player}
  end

  def report_team_slugging(team_id, the_year)
    report = "Slugging Percentages for #{team_id} #{the_year}\n"
    team_players = get_team_players(team_id, the_year)
    team_players.each do |player|
      report << "#{player.player_id}: #{player.slugging_percentage(the_year).round(3)} \n"
    end
    puts report
    report
  end

  def calc_most_improved_bat_avg
    players_2009 = filter_by_at_bats(@players, 200, 2009)
    #puts "number of players with more than 200 ABs in 2009 #{players_2009.count}"

    players_2010 = filter_by_at_bats(@players, 200, 2010)
    #puts "number of players with more than 200 ABs in 2010 #{players_2010.count}"

    # players_2009.each { |p| puts p.player_id }
    # puts "********"
    # players_2010.each { |p| puts p.player_id }
    #
    # puts "********"
    players_in_both_lists = players_2010 & players_2009

    sorted = players_in_both_lists.sort { |a, b| (b.batting_average(2010) - b.batting_average(2009)) <=> (a.batting_average(2010) - a.batting_average(2009)) }
    sorted.each { |p| puts "#{p.player_id} #{p.batting_average(2010) - p.batting_average(2009)}" }
    winning_difference = sorted.first.batting_average(2010) - sorted.first.batting_average(2009)
    puts "***** Winning Diff = #{ winning_difference}"

    winners = sorted.select { |p| p.batting_average(2010) - p.batting_average(2009) == winning_difference }

    puts "WINNER(S): "
    winners.each { |p| puts p.player_id }
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