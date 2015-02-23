In fact MLB.MLB.com data is too noisy, instead these are two useful database:
To find people faces:
http://www.baseball-reference.com
To find people statistics:
http://www.retrosheet.org/game.htm

How to find statistics:
1. Provide correct url
	find the url from http://www.retrosheet.org/boxesetc/2013/Y_2013.htm
	1). choose your team by clicking the team button
	2). once in click on “Complete Roster (Alphabetic)”
	3). copy the url
 	your url should be something like: 
	http://www.retrosheet.org/boxesetc/2013/UATL02013.htm

2. python sitecopy.py url team_name 0

How to find images:
1. Provide correct url
	find the url from http://www.baseball-reference/teams.com
	1)find your team’s abbreviation. For example yankees: NYY, Red sock: BOS
	2)find your year
	3) your url should be something like :
	http://www.baseball-reference.com/teams/BOS/2014.shtml
			
2. python sitecopy.py url team_name 1
