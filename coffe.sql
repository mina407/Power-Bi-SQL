use coffe_sales ;
 
-- to convert data type for date and time  at frist using update statement 
UPDATE coffe_shop 
SET transaction_date = STR_TO_DATE(transaction_date, '%m/%d/%Y');

alter table coffe_shop
modify column transaction_date date ;   

update coffe_shop 
set transaction_time = str_to_date(transaction_time, '%H:%i:%s') ; 

alter table coffe_shop 
modify transaction_time time ; 

describe coffe_shop ; 

-- rename the column 
alter table coffe_shop 
change transaction_id id int ; 

rename table coffe_shop to coffe ; 
select * from coffe ;
describe coffe ;

-- KPI's Requirements :-
-- 1. total sales 
select concat(round(sum(unit_price * transaction_qty))/1000 , 'K') as total_sales 
from coffe 
where 
month(transaction_date) = 5 ;
-- __________________________________________________________________________________________________
-- calculate groth by month  
select 
	month(transaction_date) as month ,
    round(sum(unit_price * transaction_qty)) as Total_sales ,
    round((sum(unit_price * transaction_qty) - lag(sum(unit_price * transaction_qty) , 1)
    over(order by month(transaction_date)))
    / 
    lag(sum(unit_price *transaction_qty ) , 1) over(order by month(transaction_date)) * 100,2 )as mom_percentage 
    from coffe 
    
    group by 
		month(transaction_date)
	order by 
		month(transaction_date) ; 

-- total orders 
select count(distinct id) as total_orders
from coffe 
where month(transaction_date) = 5 ;
-- ________________________________________________________________________________________________________________________
-- MOM regarding orders 
select 
	month(transaction_date) as Month ,-- frist col for month 
    round(count(id)) as Total_orders , -- second_col for total orders
    (count(id) - lag(count(id) , 1) over(order by month(transaction_date))) -- to count all orders in each month in arranged way asc
    /
    lag(count(id) , 1) over(order by month(transaction_date)) * 100 as MOM_percentag 
    from 
		coffe
	group by 
		month(transaction_date) 
    order by 
		month(transaction_date)
    ;
    -- total quantity sold 
    select sum(transaction_qty) as total_quantit_sold
    from coffe 
    where month(transaction_date) = 5;
-- ______________________________________________________________________________________________
-- calculate groth for quantity sold 
select 
	month(transaction_date) as Month , 
    sum(transaction_qty) as total_quantit_sold , 
   round( (sum(transaction_qty) - lag(sum(transaction_qty) , 1) over(order by month(transaction_date))) 
    / 
    lag(sum(transaction_qty) , 1) over(order by month(transaction_date)) *100 ,2)as MOM_quantit_sold
    from 
		coffe 
	group by 
		Month 
    order by 
		Month ; 
-- ___________________________________________________________-_
-- calculate total sales ,quantity sold and oreders in 2023-18-5
select 
	concat(ROUND(sum(unit_price *transaction_qty)/1000,1) , 'K')as total_sales ,
    sum(transaction_qty) as total_quantit_sold  , 
    count(id) as total_orders 
    from
		coffe 
	where 
		transaction_date = '2023-05-18';
-- ___________________________________________________________________________
-- calculate total sales in weekdays and weekend
select
	case when dayofweek(transaction_date) in (1,7) then 'Weekend'
    else 'Weekdays'
    end as day_type , 
    concat(round(sum(unit_price *transaction_qty) /1000 , 1),'K') as total_sales 
    from 
		coffe 
	where month(transaction_date) = 5
	group by day_type ;
-- ____________________________________________________________________________
        
-- total_sales by store location
select
	store_location , 
    concat(round(sum(unit_price *transaction_qty) /1000,1) , 'K') as total_sales 
    from 
		coffe 
	where 
		month(transaction_date) = 5
	group by store_location 
    
	order by 
		total_sales desc ; 
-- _______________________________________________________________________
-- average for may 
select 
	round(avg(total_sales)) as Avg_sales 
from 
	(
    select sum(unit_price *transaction_qty) as total_sales 
	from coffe 
	where month(transaction_date) = 5
	group by transaction_date
    ) as intern_query
;
-- ___________________________________________________________________
-- sales for each day 
select 
	day(transaction_date) as day_of_month ,
    round(sum(unit_price *transaction_qty) , 1) as total_sales
    from coffe 
    where month(transaction_date) = 5
    group by transaction_date; 

-- ___________________________________________________________________        
-- which day is greater than the avg of the specefied month 

select day_of_month , 
	case 
		when total_sales > avg_sales then "Above Avg"
        when total_sales < avg_sales then "Below Avg"
        else 'equal to avg'
	end as Sales_status ,
    total_sales , avg_sales
from(
		select
		day(transaction_date) as day_of_month , -- for day number 
		round(sum(unit_price *transaction_qty)) as total_sales , -- total sales for each day 
		round(avg(sum(unit_price *transaction_qty))over(),1)  as avg_sales  -- avg of specefied month
		from coffe
		where 
			month(transaction_date) = 5
		group by 
			day_of_month ) as internal_table ;
            
-- _______________________________________________
-- sales with respect to product_category 
select product_category ,
	round(sum(unit_price *transaction_qty)) as total_sales 
    from 
		coffe 
	where 
		month(transaction_date) = 5 
	group by 
		product_category 
	order by  total_sales ;
    
-- _______________________________________________
-- sales with respect to product_type top 10 
select product_type ,
	round(sum(unit_price *transaction_qty)) as total_sales 
    from 
		coffe 
	where 
		month(transaction_date) = 5 
	group by 
		product_type 
	order by  total_sales desc
    limit 10 ;
-- ____________________________________________________________________ 
-- total sales total_quanitiy and aorders with respect to may monday hour number 8 
select 
	round(sum(unit_price *transaction_qty) , 1) as total_sales , 
    sum(transaction_qty) as total_quantity , 
    count(*) as total_orders 
    from coffe 
    where month(transaction_date) = 5 -- may
    and dayofweek(transaction_date) = 2 -- monday
    and hour(transaction_time) = 8; 
-- ____________________________________________________________
-- total sales with respect to hours
select 
	hour(transaction_time) as Hour , 
	round(sum(unit_price *transaction_qty) , 1) as total_sales , 
    sum(transaction_qty) as total_quantity , 
    count(*) as total_orders 
    from coffe 
    where 
		month(transaction_date) = 5 -- may
	group by
		Hour 
	order by 
		total_sales desc ; 
-- ______________________________________________
select 
	case 
		when dayofweek(transaction_date) = 2 then 'Monday'
		when dayofweek(transaction_date) = 3 then 'Tuesday'
		when dayofweek(transaction_date) = 4 then 'Wednesday'
		when dayofweek(transaction_date) = 5 then 'Thursday'
		when dayofweek(transaction_date) = 6 then 'Friday'
		when dayofweek(transaction_date) = 7 then 'Saturday'
        else 'Sunday'
	end as Day_of_week ,
	round(sum(unit_price *transaction_qty)) as total_sales 
    from coffe 
    where 
		month(transaction_date) = 5 
	group by 
		Day_of_week 
    order by 
		total_sales desc ; 




	 



















