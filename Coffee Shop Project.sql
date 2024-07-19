use coffee;
select * FROM `coffee shop sales`;
describe `coffee shop sales`;

UPDATE `coffee shop sales`
SET transaction_date = STR_TO_DATE(transaction_date, '%m/%d/%Y');

Alter table `coffee shop sales`
Modify Column transaction_date DATE;


UPDATE `coffee shop sales`
SET transaction_time = STR_TO_DATE(transaction_time, '%H:%i:%s');

Alter table `coffee shop sales`
Modify Column transaction_time TIME;


-- Total sales for each months
Select Month(transaction_date), round(sum(transaction_qty*unit_price),2) as total_sales
from `coffee shop sales`
group by 1;

SELECT ROUND(SUM(unit_price * transaction_qty)) as Total_Sales 
FROM `coffee shop sales` 
WHERE MONTH(transaction_date) = 5; -- for month of (CM-May)


-- TOTAL SALES KPI - MOM DIFFERENCE AND MOM GROWTH
SELECT 
    MONTH(transaction_date) AS month,
    ROUND(SUM(unit_price * transaction_qty)) AS total_sales,
    (SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty), 1)
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(unit_price * transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    `coffee shop sales`
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for months of April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);
    
    -- Total number of orders for each months
Select Month(transaction_date), count(transaction_id) as total_orders
from `coffee shop sales`
group by 1;

SELECT count(transaction_id) as total_orders
FROM `coffee shop sales`
WHERE MONTH(transaction_date) = 5; -- for month of (CM-May)

-- TOTAL ORDERS - MOM DIFFERENCE AND MOM GROWTH
SELECT 
    MONTH(transaction_date) AS month,
    count(transaction_id) as total_orders,
    (count(transaction_id) - LAG(count(transaction_id), 1)
    OVER (ORDER BY MONTH(transaction_date))) / LAG(count(transaction_id), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    `coffee shop sales`
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for months of April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);
    
    -- Total quantity sold
    Select Month(transaction_date), sum(transaction_qty) as total_quantity
from `coffee shop sales`
group by 1;

SELECT sum(transaction_qty) as total_quantity
FROM `coffee shop sales`
WHERE MONTH(transaction_date) = 5; -- for month of (CM-May)

-- TOTAL QUANTITY SOLD - MOM DIFFERENCE AND MOM GROWTH
SELECT 
    MONTH(transaction_date) AS month,
    sum(transaction_qty) as total_quantity,
    (sum(transaction_qty)- LAG(sum(transaction_qty), 1)
    OVER (ORDER BY MONTH(transaction_date))) / LAG(sum(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    `coffee shop sales`
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for months of April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);
    
-- CALENDAR TABLE – DAILY SALES, QUANTITY and TOTAL ORDERS
select
concat(round(sum(transaction_qty*unit_price)/1000,1),'K') as total_sales,
concat(round(sum(transaction_qty)/1000,1),'K') as quantity_sold,
concat(round(count(transaction_id)/1000,1),'K') as total_orders
from `coffee shop sales`
where transaction_date = '2023-05-18';

-- SALES BY WEEKDAY / WEEKEND
select
case 
when  
dayofweek(transaction_date) in (1,7) then 'weekends' else 'weekdays'
end as date_type , concat(round(sum(transaction_qty*unit_price)/1000,1),'K') as total_sales
from `coffee shop sales`
group by 1;

select
case 
when  
dayofweek(transaction_date) in (1,7) then 'weekends' else 'weekdays'
end as date_type , concat(round(sum(transaction_qty*unit_price)/1000,1),'K') as total_sales
from `coffee shop sales`
where month(transaction_date) = 5
group by 1;

-- Sales by Store Locations
select store_location, concat(round(sum(transaction_qty*unit_price)/1000,1),'K') as total_sales
from `coffee shop sales`
group by 1
order by 2 DESC;

-- Daily sales for selected month
select day(transaction_date) as date_of_month, concat(round(sum(transaction_qty*unit_price)/1000,1),'K') as daily_sales
from `coffee shop sales`
where month(transaction_date) = 5
group by 1;

-- Average of total sales 
select concat(avg(total_sales),'K') as avg_sales
from(
select concat(round(sum(transaction_qty*unit_price)/1000,1),'K') as total_sales
from `coffee shop sales` ) as total_s;


-- Average of total sales for each day in selected month
select concat(round(sum(transaction_qty*unit_price)/1000,1),'K') as total_sales
from `coffee shop sales`
where month(transaction_date) = 5
group by transaction_date;

select day_of_month, concat(avg(total_sales),'K') as avg_sales
from(
select day(transaction_date) as day_of_month, concat(round(sum(transaction_qty*unit_price)/1000,1),'K') as total_sales
from `coffee shop sales`
where month(transaction_date) = 5
group by day(transaction_date)) as total_s
group by 1 ;

-- COMPARING DAILY SALES WITH AVERAGE SALES – IF GREATER THAN “ABOVE AVERAGE” and LESSER THAN “BELOW AVERAGE”
select day_of_month,
case 
when total_sales > avg_sales then 'ABOVE AVERAGE'
when total_sales < avg_sales then 'BELOW AVERAGE'
else 'AVERAGE'
end as sales_status,
total_sales
from (
select day(transaction_date) as day_of_month,
sum(transaction_qty*unit_price) as total_sales,
avg(sum(transaction_qty*unit_price)) over() as avg_sales
from `coffee shop sales`
where month(transaction_date) = 5 -- Filter for May
group by 1) as sales_data
group by 1;


-- Sales perfromance across product category

select product_category, sum(transaction_qty*unit_price) as total_sales
from `coffee shop sales`
group by 1
order by 2 DESC;

-- Top 10 products by sales
select product_type, sum(transaction_qty*unit_price) as total_sales
from `coffee shop sales`
group by 1
order by 2 DESC
limit 10;

-- Sales by days and hours for each months


select day(transaction_date) as day_of_month,
hour(transaction_time) as hours, sum(transaction_qty*unit_price) as total_sales
from `coffee shop sales`
where month(transaction_date) = 5 -- filter for May 
group by 1,2; 


select case 
when dayofweek(transaction_date) = 2 then 'Monday'
when dayofweek(transaction_date) = 3 then 'Tuesday'
when dayofweek(transaction_date) = 4 then 'Wednesday'
when dayofweek(transaction_date) = 5 then 'Thursday'
when dayofweek(transaction_date) = 6 then 'Friday'
when dayofweek(transaction_date) = 7 then 'Saturday'
else 'Sunday'
end as day_of_week,
hour(transaction_time) as hours, sum(transaction_qty*unit_price) as total_sales
from `coffee shop sales`
where month(transaction_date) = 5 -- filter for May 
group by 1,2;


