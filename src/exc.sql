delimiter $$
create procedure usp_get_employees_salary_above_35000 ()
#that returns all employees' first and last names for whose salary is above 35000
begin
    return (select e.first_name, e.last_name
            from employees as e
            where salary >35000
            order by first_name,last_name,id);
end
$$
