create database fsd;

use fsd;


create table coaches
(
    id          int primary key,
    first_name  varchar(10),
    last_name   varchar(20),
    salary      decimal(10, 2),
    coach_level int
);

create table countries
(
    id   int primary key,
    name varchar(45)
);

create table towns
(
    id         int,
    name       varchar(45),
    country_id int,
    primary key (id),
    foreign key (country_id) references countries (id)
);

create table stadiums
(
    id       int,
    name     varchar(45),
    capacity int,
    town_id  int,
    primary key (id),
    foreign key (town_id) references towns (id)
);

create table teams
(
    id          int,
    name        varchar(45),
    established date,
    fan_base    bigint(20),
    stadium_id  int,
    primary key (id),
    foreign key (stadium_id) references stadiums (id)
);

create table skills_data
(
    id        int,
    dribbling int,
    pace      int,
    passing   int,
    shooting  int,
    speed     int,
    strength  int,
    primary key (id)
);

create table players
(
    id             int,
    first_name     varchar(10),
    last_name      varchar(20),
    age            int,
    position       char(1),
    salary         decimal(10, 2),
    hire_date      datetime,
    skills_data_id int,
    team_id        int,
    primary key (id),
    foreign key (skills_data_id) references skills_data (id),
    foreign key (team_id) references teams (id)
);

create table players_coaches
(
    player_id int,
    coach_id  int,
    primary key (player_id, coach_id)
);