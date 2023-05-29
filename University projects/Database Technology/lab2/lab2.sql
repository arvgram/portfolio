DROP TABLE IF EXISTS theatres;
CREATE TABLE theatres (
	name			TEXT,    
 	capacity  		INT,
	PRIMARY KEY  		(name)
);

DROP TABLE IF EXISTS movies;
CREATE TABLE movies (
	name			TEXT,    
 	year	  		INT,
	imdb_key		TEXT,
	running_time		INT,

	PRIMARY KEY  		(name,year)
);

DROP TABLE IF EXISTS screenings;
CREATE TABLE screenings (
	theatre_name	TEXT,
  	start_time	TIME,
  	date		DATE,
	movie_name	TEXT,
	production_year	INT,
	screening_id 	TEXT DEFAULT (lower(hex(randomblob(16))))
	
	
  	PRIMARY KEY	(theatre_name, start_time, date),
  	FOREIGN KEY	(theatre_name) REFERENCES theatres(name),
  	FOREIGN KEY	(movie_name, production_year) REFERENCES movies(name, year)
);

DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
	user_name	TEXT PRIMARY KEY,
  	full_name	TEXT,
  	password	TEXT	
);

DROP TABLE IF EXISTS tickets;
CREATE TABLE tickets(
	ticket_number	TEXT DEFAULT (lower(hex(randomblob(16)))),
  	start_time	TIME,
  	date		DATE,
	theatre		TEXT,
	user_name	TEXT,	

  	PRIMARY KEY	(ticket_number),
  	FOREIGN KEY	(theatre, start_time, date) REFERENCES screenings(theatre,start_time,date),
	FOREIGN KEY	(user_name) REFERENCES customer(user_name)
);

INSERT
INTO 	theatres(name,capacity)
VALUES	("Rigoletto", 900),
	("Söder", 150),
	("Victoria", 220),
	("Astoria", 450); 	

INSERT
INTO 	movies(name,year,imdb_key, running_time)
VALUES	("The Godfather", 1972,"tt3922", 175),
	("The Godfather 2", 1974,"tt3923", 202),
	("The Godfather 3", 1992,"tt3953", 162),
	("The Gentlemen", 2019, "tt3221", 163);

INSERT
INTO 	screenings(theatre_name, start_time, date, movie_name, production_year)
VALUES	("Rigoletto", '19:30', '2022-02-01', "The Godfather", 1972),
	("Söder", '17:30', '2022-02-02', "The Gentlemen", 2019),
	("Victoria", '18:00', '2022-02-01', "The Godfather", 1972),
	("Victoria", '21:15', '2022-02-01', "The Godfather", 1972);

INSERT
INTO 	customers(user_name, full_name, password)
VALUES	('kingen', 'Arvid Gramer', 'hejsan'),
	('fransan', 'Fanny Spindler Lagercrantzz', 'arvid<3'),
	('persimon', 'Simon Danielsson', 'cmdlinerules'),
	('chuppen', 'Charlie Nilsson', 'snartFårJagSpelaWoW'),
	('nelson11', 'Nils Romanus Myrberg', 'snartFårJagSpelaWoW');

INSERT
INTO 	tickets(ticket_number, start_time, date, theatre, user_name)
VALUES	('002212', '19:30', '2022-02-01', 'Rigoletto', 'kingen'),
	('002213', '19:30', '2022-02-01', 'Rigoletto', 'fransan'),
	('001233', '19:30', '2022-02-01', 'Rigoletto', 'persimon'),
	('002214', '19:30', '2022-02-01', 'Rigoletto', 'chuppen'),
	('002241', '19:30', '2022-02-01', 'Rigoletto', 'nelson11');




