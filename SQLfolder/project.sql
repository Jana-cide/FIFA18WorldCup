CREATE TABLE team(
	team_id VARCHAR(50) PRIMARY KEY,
	rank INTEGER,
	team_name VARCHAR(20) NOT NULL,
	no_of_wins INTEGER,
	no_of_losses INTEGER,
	no_of_draws INTEGER,
	no_of_defenders INTEGER,
	no_of_strikersmid INTEGER
);

INSERT INTO team 
VALUES
('FRA123',1,'France',2,0,1,8,12),
('PER456',3,'Peru',1,2,0,8,12),
('AUS153',4,'Australia',0,2,1,6,14),
('DEN426',2,'Denmark',1,0,2,7,13);

CREATE TABLE goalkeeper(
	team_id VARCHAR(50) REFERENCES team(team_id),
	gk_name VARCHAR(30)
);

INSERT INTO goalkeeper
VALUES
('DEN426','Kasper Schmeichel'),
('FRA123','Hugo Lloris'),
('FRA123','Alphonse Areola'),
('AUS153','Mat Ryan'),
('PER456','Pedro Gallese');

CREATE TABLE refrees(
	ref_id SERIAL PRIMARY KEY,
	ref_name VARCHAR(30),
	no_of_matches INTEGER,
	country VARCHAR(20)
);

INSERT INTO referees
(ref_name,no_of_matches,country)
VALUES
('Mike Dean',418,'England'),
('Antonio Lahoz',311,'Spain'),
('Bibiana Steinhaus',173,'Germany'),
('Martin Akinson',397,'England');

CREATE TABLE player(
	player_id SERIAL PRIMARY KEY,
	team_id VARCHAR(50) REFERENCES team(team_id),
	no_of_worldcups INTEGER,
	number_of_matches INTEGER,
	avgrating REAL,
	goal_cont INTEGER, 
	chances_per_ninety REAL,
	blocks_per_ninety REAL,
	interceptions_per_ninety REAL,
	type_of_player VARCHAR(25)
);

INSERT INTO player(
	team_id,
	no_of_worldcups,
	number_of_matches,
	avgrating,
	goal_cont,
	chances_per_ninety,
	blocks_per_ninety,
	interceptions_per_ninety,
	type_of_player
)
VALUES
('FRA123',1,7,8.2,6,1.3,0.3,0.8,'Forward'),
('PER456',1,7,6.4,1,0.2,1.4,1.9,'Defender'),
('FRA123',2,11,7.2,4,1.6,0.5,0.6,'Midfielder'),
('AUS153',1,3,5.6,0,0.1,0.9,1.1,'Defender'),
('DEN426',3,6,7.1,2,1.4,0.4,0.6,'Midfielder');

CREATE TABLE coach(
	coach_id SERIAL PRIMARY KEY,
	team_id VARCHAR(50) REFERENCES team(team_id),
	coach_name VARCHAR(30)
);

INSERT INTO coach(
	team_id,
	coach_name
)
VALUES
('FRA123','Didier Deschamps'),
('PER456','Ricardo Gareca'),
('AUS153','Graham Arnold'),
('DEN426','Kasper Hjulmand');

CREATE TABLE captain(
	captain_id SERIAL PRIMARY KEY,
	captain_name VARCHAR(30),
	team_id VARCHAR REFERENCES team(team_id),
	player_id VARCHAR(30),
	year_of_captaincy INTEGER,
	no_of_wins INTEGER
);

INSERT INTO captain(
	captain_name,
	team_id,
	player_id,
	year_of_captaincy,
	no_of_wins
)
VALUES
('Hugo Lloris','FRA123','PLR123',10,55),
('Simon Kjaer','DEN426','PLR426',3,16),
('Paolo Guerrero','PER456','PLR456',5,23),
('Mark Milligan','AUS153','PLR153',2,6);

CREATE TABLE matches(
	match_id SERIAL PRIMARY KEY,
	match_date_time TIMESTAMPTZ,
	team1 VARCHAR(30),
	team2 VARCHAR(30),
	loser VARCHAR(30),
	winner VARCHAR(30),
	stadium VARCHAR(30),
	ref_id INTEGER REFERENCES referees(ref_id)
);

INSERT INTO matches(
	match_date_time,
	team1,
	team2,
	loser,
	winner,
	stadium,
	ref_id
)
VALUES
(TO_TIMESTAMP('16-06-2018 13:00:00','dd-mm-yyyy hh24:mi:ss'),'France','Australia','Australia','France','Kazan Arena',1),
(TO_TIMESTAMP('16-06-2018 19:00:00','dd-mm-yyyy hh24:mi:ss'),'Peru','Denmark','Peru','Denmark','Mordovia Arena',2),
(TO_TIMESTAMP('21-06-2018 19:00:00','dd-mm-yyyy hh24:mi:ss'),'Denmark','Australia','-','-','Cosmos Arena',3),
(TO_TIMESTAMP('21-06-2018 20:00:00','dd-mm-yyyy hh24:mi:ss'),'France','Peru','Peru','France','Central Stadium',4),
(TO_TIMESTAMP('26-06-2018 17:00:00','dd-mm-yyyy hh24:mi:ss'),'Denmark','France','-','-','Luzhniki Stadium',2),
(TO_TIMESTAMP('26-06-2018 17:00:00','dd-mm-yyyy hh24:mi:ss'),'Australia','Peru','Australia','Peru','Fisht Olympic Stadium',3);

CREATE TABLE plays(
	team_id VARCHAR(50) REFERENCES team(team_id),
	match_id INTEGER REFERENCES matches(match_id)
);

INSERT INTO plays
VALUES
('FRA123',1),
('DEN426',2),
(NULL,3),
('FRA123',4),
(NULL,5),
('PER456',6);

CREATE TABLE refereed_by(
	match_id INTEGER REFERENCES matches(match_id),
	ref_id INTEGER REFERENCES referees(ref_id)
);

INSERT INTO refereed_by
VALUES
(1,1),
(2,2),
(3,3),
(4,4),
(5,2),
(6,3);

--ALTER STATEMENT
ALTER TABLE team ADD total_matches INTEGER;

UPDATE team SET total_matches=no_of_wins+no_of_losses+no_of_draws;

ALTER TABLE player ADD player_name VARCHAR(20);

UPDATE player 
SET player_name =
(CASE player_id
 	WHEN 1 THEN 'Kyllian Mbappe'
 	WHEN 2 THEN 'Miguel Araujo'
 	WHEN 3 THEN 'Paul Pogba'
 	WHEN 4 THEN 'James Meredith'
 	WHEN 5 THEN 'Christian Eriksen'
END 
);

--NESTED STATEMENTS
SELECT ref_name FROM referees WHERE ref_id NOT IN 
(SELECT DISTINCT ref_id FROM matches WHERE stadium='Cosmos Arena'); # referees who have not refereed games in Cosmos Arena

SELECT DISTINCT coach_name FROM coach WHERE team_id IN 
(SELECT team_id FROM player WHERE avgrating>7); #coaches with player whose average rating is more than 7

SELECT DISTINCT coach_name from coach INNER JOIN player ON coach.team_id
= player.team_id WHERE(avgrating>7); #this sql command produces same output as previous command

SELECT team_name FROM team WHERE team_id IN 
(SELECT team_id FROM player WHERE no_of_worldcups>1); #teams with more experienced players in squad

SELECT gk_name FROM goalkeeper WHERE team_id IN
(SELECT team_id FROM captain WHERE captain_name=gk_name); #Displaying names of goalkeepers who also captain their side

SELECT coach_name FROM coach WHERE team_id IN 
(SELECT team_id FROM plays WHERE match_id IN
(SELECT match_id FROM matches WHERE TO_CHAR(match_date_time,'HH24:MI:SS')>'18:00:00')); # names of coaches whose teams won matches that happened after 6pm local time

SELECT player_id,player_name FROM player WHERE type_of_player IN 
(SELECT type_of_player FROM player GROUP BY type_of_player HAVING COUNT(*)>1);#if count of particular type of player >1 ,then display name,id of all such players

ALTER TABLE player DROP COLUMN number_of_matches;

SELECT * FROM team ORDER BY rank LIMIT 2;
--> Top two teams in the tournament are displayed!









