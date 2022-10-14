# 1. Table design

-- create database softuni_imdb;
-- use softuni_imdb;


create table countries
(
    id        int primary key auto_increment,
    name      varchar(30) not null unique,
    continent varchar(30) not null,
    currency  varchar(5)  not null
);

create table genres
(
    id   int primary key auto_increment,
    name varchar(50) not null unique
);

create table actors
(
    id         int primary key auto_increment,
    first_name varchar(50) not null,
    last_name  varchar(50) not null,
    birthdate  date        not null,
    height     int,
    awards     int,
    country_id int         not null,
    foreign key (`country_id`) references countries (`id`)
);

create table movies_additional_info
(
    id            int primary key auto_increment,
    rating        decimal(10, 2) not null,
    runtime       int            not null,
    picture_url   varchar(80)    not null,
    budget        decimal(10, 2),
    release_date  date           not null,
    has_subtitles tinyint(1),
    `description` text
);

create table movies
(
    id            int primary key auto_increment,
    title         varchar(70) not null unique,
    country_id    int         not null,
    movie_info_id int         not null unique,
    foreign key (`country_id`) references countries (`id`),
    foreign key (`movie_info_id`) references movies_additional_info (`id`)
);

create table movies_actors
(
    movie_id int,
    actor_id int,
    FOREIGN KEY (`movie_id`) REFERENCES movies (id),
    FOREIGN KEY (`actor_id`) REFERENCES actors (id)
);

create table genres_movies
(
    genre_id int,
    movie_id int,
    FOREIGN KEY (`genre_id`) REFERENCES genres (id),
    FOREIGN KEY (`movie_id`) REFERENCES movies (id)
);


# 2. Insert

insert into actors (first_name, last_name, birthdate, height, awards, country_id)
select (reverse(a.first_name)),
       (reverse(a.last_name)),
       date(a.birthdate - 2),
       (a.height + 10),
       (a.country_id),
       (3)
from actors as a
where a.id <= 10;

# 3. Update

update movies_additional_info
set runtime = runtime - 10
where id >= 15
  and id <= 25;

# 4. Delete

delete c
from countries as c
         left join movies as m on c.id = m.country_id
where m.country_id is null;

# 5. Countries

select *
from countries as c
order by currency desc, id;

# 6. Old movies

select mai.id           as id,
       m.title          as title,
       mai.runtime      as runtime,
       mai.budget       as budget,
       mai.release_date as release_date
from movies_additional_info as mai
         join movies as m on m.movie_info_id = mai.id
where year(mai.release_date) between 1996 and 1999
order by runtime, id
limit 20;

# 7. Movie casting

select concat_ws(' ', first_name, last_name)                             as full_name,
       concat(reverse(a.last_name), char_length(last_name), '@cast.com') as email,
       (2022 - year(a.birthdate))                                        as age,
       a.height
from actors as a
         left join movies_actors as ma on a.id = ma.actor_id
where ma.movie_id is null
order by height;

# 8. International festival

select c.name      as name,
       count(m.id) as movies_count
from countries as c
         join movies as m on c.id = m.country_id
group by c.name
having movies_count >= 7
order by name desc;

# 9. Rating system

select mv.title                            as title,
       (case
            when m.rating <= 4 then 'poor'
            when m.rating <= 7 then 'good'
            else 'excellent' end)          as rating,
       if(m.has_subtitles, 'english', '-') as subtitles,
       m.budget                            as budget
from movies as mv
         join movies_additional_info as m on mv.movie_info_id = m.id
order by budget desc;

# 10. History movies

delimiter $$
create function udf_actor_history_movies_count(full_name VARCHAR(50))
    returns int
    deterministic
begin
    return (select count(g.name)
            from actors as a
                     join movies_actors as ma on ma.actor_id = a.id
                     join genres_movies as gm on gm.movie_id = ma.movie_id
                     join genres as g on g.id = gm.genre_id
            where concat_ws(' ', a.first_name, a.last_name) = full_name
              and g.name = 'history');
end
$$


select udf_actor_history_movies_count('Stephan Lundberg');

