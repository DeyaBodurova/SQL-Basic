
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