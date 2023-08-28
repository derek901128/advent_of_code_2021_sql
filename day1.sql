with 
base(d) as 
(
    select 199 from dual union all
	select 200 from dual union all
	select 208 from dual union all
	select 210 from dual union all
	select 200 from dual union all
	select 207 from dual union all
	select 240 from dual union all
	select 269 from dual union all
	select 260 from dual union all
	select 263 from dual
),
add_rn as 
(
    select 
    	row_number()over(order by rownum) as rn,
    	d
    from 
    	base
),
add_rolling_sum as 
(
    select 
    	rn,
    	d,
    	sum(d) over(order by rn rows between 2 preceding and current row) as rolling_sum
    from
    	add_rn
),
add_in_de as 
(
    select 
    	rn,
    	d,
    	case 
			when lag(d)over(order by rn) < d 
			then 'increased' 
			else 'decreased' 
		end as solution_1,
    	case 
			when lag(rolling_sum) over(order by rn) < rolling_sum 
			then 'increased' 
			else 'decreased' 
		end as solution_2
    from
    	add_rolling_sum
    where 
    	rn > 2
),
solution_1 as 
(
	select count(*) from add_in_de where solution_1 = 'increased'    
),
solution_2 as 
(
    select count(*) from add_in_de where solution_2 = 'increased'  
)
select * from solution_2;
