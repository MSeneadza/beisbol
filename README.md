# README #

This is my (Michael Seneadza - GitHub ID: MSeneadza) submission for the baseball stats coding challenge.

### Requirements: ###

When the application is run, use the provided data and calculate the following results and write them to STDOUT.

1) Most improved batting average( hits / at-bats) from 2009 to 2010.  Only include players with at least 200 at-bats.
2) Slugging percentage for all players on the Oakland A's (teamID = OAK) in 2007. 
3) Who was the AL and NL triple crown winner for 2011 and 2012.  If no one won the crown, output "(No winner)"

### Installation / Setup ###

* This was written on Ruby 2.1.2 and the Gemfile specifies / requires that version. If you need to run on a different version
   of ruby you can modify or remove that line from the Gemfile
* Extract / Copy the code into a directory.
* cd into the root of the directory from the previous step
* create and switch to a gemset if so desired
* run 'bundle' to install the required gems.
* At the command prompt type 'ruby baseball_report.rb' to generate the Hitting Stats Report, which will be output to your screen

### Running The Report ###
* cd into the directory whrere the code was copied.
* At the command prompt type 'ruby baseball_report.rb' to generate the Hitting Stats Report, which will be output to your screen

### Running Tests ###

* The Tests are written in RSpec.  Just run 'rspec spec' at the command line to run the test suite.

### Notes / Assumptions ###

I've made the following assumptions:

* Blank values in the data files for the statistics columns represents zeros.
* If a player is traded mid-season, all of his stats for that year get aggregated across teams and leagues. So, for example, 
   if a player was traded from the Braves to the Yankees in 2010 his Yankees team stats for 2010 would include what he did with the Braves.
   Likewise his Braves 2010 stats would include his Yankee stats.
* I made the above assumption b/c that seemed to fit with the 'spirit' of the requested reports, especially with regard to a
  Triple Crown winner who was traded within a league.