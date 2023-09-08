with 
base(instructions) as 
(
	select 'forward 5' from dual union all
	select 'down 5' from dual union all
	select 'forward 8' from dual union all
	select 'up 3' from dual union all
	select 'down 8' from dual union all
	select 'forward 2' from dual
),
stage_1 as 
(
    select 
    	row_number() over(order by rownum) as row_no
    	, substr
			(
				instructions
				, 1
				, length(instructions) - 2
			) as direction
    	, to_number(substr(instructions, -2)) as steps,
    	, sum
			(
	    		case substr(instructions, 1, length(instructions) - 2) 
	    			when 'forward' 
	    			then to_number(substr(instructions, -2)) 
	    			else 0 
	    		end
	    	) over() as hp
    	, sum
			(
	    		case substr(instructions, 1, length(instructions) - 2) 
	    			when 'down' 
	    			then to_number(substr(instructions, -2))
	    			when 'up' 
	    			then  to_number(substr(instructions, -2)) * -1
	    			else 0 
	    		end
	        ) over() as d
    from
    	base
),
stage_2 as 
(
    select 
    	row_number() over(order by rownum) as row_no
    	, substr
			(
				instructions
				, 1
				, length(instructions) - 2
			) as direction
    	, to_number(substr(instructions, -2)) as steps
    	, sum
			(
	    		case substr(instructions, 1, length(instructions) - 2) 
	    			when 'forward' 
	    			then to_number(substr(instructions, -2)) 
	    			else 0 
	    		end
	    	) over(order by rownum rows between unbounded preceding and current row) as hp
    	, sum
			(
	    		case substr(instructions, 1, length(instructions) - 2) 
	    			when 'down' 
	    			then to_number(substr(instructions, -2))
	    			when 'up' 
	    			then  to_number(substr(instructions, -2)) * -1
	    			else 0 
	    		end
	        ) over(order by rownum rows between unbounded preceding and current row) as aim
    from
    	base
),
solution_1 as 
(
	select distinct hp * d as answer_1 from stage_1    
),
solution_2 as 
(
    select 
    	row_no
    	, hp * sum(case direction when 'forward' then steps * aim else 0 end) over(order by row_no rows between unbounded preceding and current row) as answer_2
    from 
    	stage_2
)
select answer_2 from solution_2 where row_no = ( select max(row_no) from solution_2);
