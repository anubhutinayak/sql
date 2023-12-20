-- select * from customer_shopping_data1


-- select customer_id, gender, age, quantity, price, payment_method, shopping_mall,
-- substring_index(invoice_date, ' ', 1) invoice_date 
-- from customer_shopping_data1;

-- inspect data

-- select count(*) -- check how many records
-- from customer_shopping_data1;

-- select count(distinct(customer_id)) -- customer id has to be unique, check if it's correct
-- from customer_shopping_data1;

--  select *
-- from customer_shopping_data1 -- check if there are null values
-- where shopping_mall is null

-- spending by gender

-- select gender, sum(quantity) orders, sum(price) sales
-- from customer_shopping_data1
-- group by gender
-- order by 3 desc;

-- As we speculated, women tend to shop greater than men.

-- spending by mall

-- select shopping_mall,sum(quantity) orders, sum(price) sales
-- from customer_shopping_data1
-- group by shopping_mall
-- order by 3 desc;

-- Mall of Istanbul has the most sales,whereas Forum instalbul has least

-- top spending by year

-- select distinct(year(invoice_date)) year, gender, sum(quantity) sales, sum(price) revenue
-- from customer_shopping_data1 
-- group by year, gender
-- order by revenue desc;
  
  
--   Recency, Frequency, and Monetary

-- select
--   customer_id, gender, age, payment_method, shopping_mall, 
--   datediff('2023-03-10', invoice_date) last_date_order,
--   sum(quantity) total_orders,
--   sum(price) spending
-- from customer_shopping_data1
-- group by customer_id, gender, age, payment_method, shopping_mall, invoice_date
-- order by last_date_order


-- --coding the column as rfm recency,rfm frequency,rfm monetary
-- with rfm as (
--  select
--   customer_id, gender, age, payment_method, shopping_mall, 
--   datediff('2023-03-10', invoice_date) last_date_order,
--   sum(quantity) total_orders,
--   sum(price) spending
--  from customer_shopping_data1
--  group by customer_id, gender, age, payment_method, shopping_mall, invoice_date
--  order by last_date_order
-- )
-- select *,
--   ntile(3) over (order by last_date_order) rfm_recency,
--   ntile(3) over (order by total_orders) rfm_frequency,
--   ntile(3) over (order by spending) rfm_monetary
--  from rfm


-- --rfm score calculation


-- with rfm as (
--  select
--   customer_id, gender, age, payment_method, shopping_mall, 
--   datediff('2023-03-10', invoice_date) last_date_order,
--   sum(quantity) total_orders,
--   sum(price) spending
--  from customer_shopping_data1
--  group by customer_id, gender, age, payment_method, shopping_mall, invoice_date
--  order by last_date_order
-- ),

-- rfm_calc as (
--  select *,
--   ntile(3) over (order by last_date_order) rfm_recency,
--   ntile(3) over (order by total_orders) rfm_frequency,
--   ntile(3) over (order by spending) rfm_monetary
--  from rfm
--  order by rfm_monetary desc
-- )

-- select *, rfm_recency + rfm_frequency + rfm_monetary as rfm_score,
-- concat(rfm_recency, rfm_frequency, rfm_monetary) as rfm
-- from rfm_calc


-- RFM

select *, case
 when rfm in (311, 312, 311) then 'new customers'
 when rfm in (111, 121, 131, 122, 133, 113, 112, 132) then 'lost customers'
 when rfm in (212, 313, 123, 221, 211, 232) then 'regular customers'
 when rfm in (223, 222, 213, 322, 231, 321, 331) then 'loyal customers'
 when rfm in (333, 332, 323, 233) then 'champion customers'
end rfm_segment
from
(
with rfm as (
 select
  customer_id, gender, age, payment_method, shopping_mall, 
  datediff('2023-03-10', invoice_date) last_date_order,
  sum(quantity) total_orders,
  sum(price) spending
 from customer_shopping_data1
 group by customer_id, gender, age, payment_method, shopping_mall, invoice_date
 order by last_date_order
),

rfm_calc as (
 select *,
  ntile(3) over (order by last_date_order) rfm_recency,
  ntile(3) over (order by total_orders) rfm_frequency,
  ntile(3) over (order by spending) rfm_monetary
 from rfm
 order by rfm_monetary desc
)
select *, rfm_recency + rfm_frequency + rfm_monetary as rfm_score,
concat(rfm_recency, rfm_frequency, rfm_monetary) as rfm
from rfm_calc
) rfm_tb;
