with 
base (b) as 
(
	select '00100' from dual union all
	select '11110' from dual union all
	select '10110' from dual union all
	select '10111' from dual union all
	select '10101' from dual union all
	select '01111' from dual union all
	select '00111' from dual union all
	select '11100' from dual union all
	select '10000' from dual union all
	select '11001' from dual union all
	select '00010' from dual union all
	select '01010' from dual
),
breakup
(
    lvl
    , b
    , bb
) as 
(
    select 1, b, substr(b, 1, 1) from base 
    union all
	select 
		lvl + 1
    	, b
    	, substr(b, lvl+1, 1) 
    from
    	breakup
    where
    	lvl < length(b)
),
count_bits as 
(
    select 
    	lvl
    	, rank() over(order by lvl desc) as rank
    	, sum(case bb when '1' then 1 else 0 end) as ones
    	, sum(case bb when '1' then 0 else 1 end) as zeros
    from
    	breakup
    group by 
    	lvl
),
gamma as 
(
    select 
    	sum(case greatest(ones, zeros) when ones then 1 else 0 end * power(2, rank-1)) as gamma
    from 
    	count_bits a 
    order by 
    	lvl
),
epsilon as 
(
    select 
    	sum(case greatest(ones, zeros) when ones then 0 else 1 end * power(2, rank-1)) as epsilon
	from
    	count_bits
),
solution_1 as 
(
    select gamma * epsilon from gamma, epsilon
),
oxygen
(
    lvl
    , ones
    , zeros
    , bits
    , next_ones
    , next_zeros
) as 
(
	select 
    	1
    	, a.ones
    	, a.zeros
    	, b.b
    	, sum(regexp_count(substr(b.b, 1 + 1, 1), '1')) over(partition by a.lvl)
    	, sum(regexp_count(substr(b.b, 1 + 1, 1), '0')) over(partition by a.lvl)
    from
    	count_bits a, base b
    where 	
		a.lvl = 1
    	and substr(b.b, a.lvl, 1) = case greatest(a.ones, a.zeros) when a.ones then '1' else '0' end
    union all
    select 
		lvl + 1
    	, next_ones 
    	, next_zeros
    	, bits
    	, sum(regexp_count(substr(bits, lvl + 1 + 1, 1), '1')) over(partition by lvl)
    	, sum(regexp_count(substr(bits, lvl + 1 + 1, 1), '0')) over(partition by lvl)
    from
    	oxygen
    where 
    	substr(bits, lvl + 1, 1) = case greatest(next_ones, next_zeros) when next_ones then '1' else '0' end
    	and lvl < length(bits)
),
co2 
(
    lvl
    , ones
    , zeros
    , bits
    , next_ones
    , next_zeros
) as 
(
	select 
    	1
    	, a.ones
    	, a.zeros
    	, b.b
    	, sum(regexp_count(substr(b.b, 1 + 1, 1), '1')) over(partition by a.lvl)
    	, sum(regexp_count(substr(b.b, 1 + 1, 1), '0')) over(partition by a.lvl)
    from
    	count_bits a, base b
    where 	
		a.lvl = 1
    	and substr(b.b, a.lvl, 1) = case least(a.ones, a.zeros) when a.zeros then '0' else '1' end
    union all
    select 
		lvl + 1
    	, next_ones 
    	, next_zeros
    	, bits
    	, sum(regexp_count(substr(bits, lvl + 1 + 1, 1), '1')) over(partition by lvl)
    	, sum(regexp_count(substr(bits, lvl + 1 + 1, 1), '0')) over(partition by lvl)
    from
    	co2
    where 
    	substr(bits, lvl + 1, 1) = case least(next_ones, next_zeros) when next_zeros then '0' else '1' end
    	and lvl < length(bits)
),
breakup_2 
(
    cata
    , power
    , b
) as 
(
    select 
    	'oxygen'
    	, rank()over(order by level desc) - 1
    	, substr(bits, level, 1) 
    from 
    	( select * from oxygen where lvl = (select max(lvl) from oxygen)) 
    connect by 
    	level <= length(bits)
    union all
    select 
    	'co2', 
    	, rank() over(order by level desc) - 1
    	, substr(bits, level, 1) 
    from 
    	( select * from co2 where lvl = (select max(lvl) from co2)) 
    connect by 
    	level <= length(bits)
),
solution_2 as (
    select 
    	sum(case cata when 'oxygen' then to_number(b) else 0 end * power(2, power)) * sum(case cata when 'co2' then to_number(b) else 0 end * power(2, power)) as answer_2
    from
    	breakup_2
)
select * from solution_2;
