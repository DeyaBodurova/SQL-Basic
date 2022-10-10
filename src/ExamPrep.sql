create database fsd;

use fsd;

# 1. Create tables

create table coaches
(
    id          int primary key auto_increment,
    first_name  varchar(10)                not null,
    last_name   varchar(20)                not null,
    salary      decimal(10, 2) default (0) not null,
    coach_level int            default (0) not null
);
create table countries
(
    id   int primary key,
    name varchar(45)
);

create table towns
(
    id         int auto_increment,
    name       varchar(45) not null,
    country_id int         not null,
    primary key (id),
    foreign key (country_id) references countries (id)
);

create table stadiums
(
    id       int auto_increment,
    name     varchar(45) not null,
    capacity int         not null,
    town_id  int         not null,
    primary key (id),
    foreign key (town_id) references towns (id)
);

create table teams
(
    id          int auto_increment,
    name        varchar(45)            not null,
    established date                   not null,
    fan_base    bigint(20) default (0) not null,
    stadium_id  int                    not null,
    primary key (id),
    foreign key (stadium_id) references stadiums (id)
);

create table skills_data
(
    id        int auto_increment,
    dribbling int default (0),
    pace      int default (0),
    passing   int default (0),
    shooting  int default (0),
    speed     int default (0),
    strength  int default (0),
    primary key (id)
);

create table players
(
    id             int auto_increment,
    first_name     varchar(10)                not null,
    last_name      varchar(20)                not null,
    age            int            default (0) not null,
    position       char(1)                    not null,
    salary         decimal(10, 2) default (0) not null,
    hire_date      datetime,
    skills_data_id int                        not null,
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

# 2. Insert

insert into coaches(first_name, last_name, salary, coach_level)
    (select p.first_name,
            p.last_name,
            p.salary * 2                      as salary,
            concat(char_length(p.first_name)) as coach_level
     from players as p
     where p.age >= 45);

# 3. Update

update coaches as c
set c.coach_level = c.coach_level + 1
where (c.first_name like 'a%')
  and c.id in (select coach_id from players_coaches);

# 4. Delete

delete
from players as p
where p.age >= 45;

# 5. Players

SELECT first_name, age, salary
FROM players
order by salary desc;

# 6. Young offense players without contract

SELECT id,
       concat_ws(' ', p.first_name, p.last_name) as full_name,
       age,
       position,
       hire_date
FROM players as p
where p.age < 23
  and position = 'A'
  and hire_date is null
  and skills_data_id in
      (select id from skills_data where strength > 50)
order by salary, age;

# 7. Detail info for all teams

SELECT t.name              as team_name,
       t.established,
       t.fan_base,
       count(p.first_name) as players_count
FROM teams as t
         left join players as p on t.id = p.team_id
group by t.id
order by players_count desc, fan_base desc;

