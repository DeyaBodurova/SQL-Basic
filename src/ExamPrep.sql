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

# 8. The fastest player by town

select Max(sd.speed) as max_speed,
       towns.name    as town_name
from skills_data as sd
         join players as p on sd.id = p.skills_data_id
         right join teams as t on p.team_id = t.id
         join stadiums as s on s.id = t.stadium_id
         join towns on towns.id = s.town_id
where t.name != 'Devify'
group by towns.id
order by max_speed desc, town_name;

# 9. Total salaries and players by country

select c.name        as name,
       (count(p.id)) as total_count_of_players,
       sum(p.salary) as total_sum_of_salaries
from countries as c
         left join towns as tw on c.id = tw.country_id
         left join stadiums as st on tw.id = st.town_id
         left join teams on st.id = teams.stadium_id
         left join players as p on teams.id = p.team_id
group by c.name
order by total_count_of_players desc, name;


# 10. Find all players that play on stadium

delimiter $$
create function udf_stadium_players_count(stadium_name VARCHAR(30))
    returns int
    deterministic
begin
    return
        (select count(p.id)
         from players as p
                  join teams as t on p.team_id = t.id
                  join stadiums as s on t.stadium_id = s.id
         where s.name = stadium_name);
end
$$

# 11. Find good playmaker by teams

delimiter $$
create procedure udp_find_playmaker(min_dribble_points int,
                                    team_name varchar(45))
begin
    select concat(p.first_name, ' ', p.last_name) as full_name,
           p.age,
           p.salary,
           sk.dribbling,
           sk.speed,
           tm.name
    from players as p
             join skills_data as sk on p.skills_data_id = sk.id
             join teams as tm on p.team_id = tm.id
    where sk.dribbling > min_dribble_points
      and tm.name = team_name
      and sk.speed > (select avg(speed) from skills_data)
    order by speed desc
    limit 1;
end
$$
