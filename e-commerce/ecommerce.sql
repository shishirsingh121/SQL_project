create database ecommerce;
use ecommerce;

select * from orders
-- 1.Calculate total revenue per month (use price + freight_value).
select month(OrderDate) as 'months',sum(TotalAmount) as 'total_amont'  from orders group by months order by months;


-- 2.Find total TotalAmount for each Category.
select Category,sum(TotalAmount) as 'Total' from orders group by Category;


-- 3.Average rating by brand
-- Compute average Rating for every Brand.
select Brand,avg(Rating) as 'avg' from orders group by Brand;


-- 4.Top 5 most sold products
-- Order by SUM(Quantity) and return only top 5.
select Product,sum(Quantity) as 'total_qantity' from orders group by Product limit 5;

select* from orders
-- 5.Orders by platform
-- Count how many orders come from each Platform.

select Platform,sum(Quantity) as 'total_order' from orders group by Platform;

-- 6.Highest priced product in each category
-- Show Category, Product, Max(Price).
select * from (
select *,row_number() over(partition by Category order by price desc) as ran from orders
)z
where ran=1


-- 6️. City revenue ranking
-- List cities sorted by total TotalAmount (highest first)
select City,sum(TotalAmount) as 'total', RANK() OVER (ORDER BY SUM(TotalAmount) DESC) AS revenue_rank from orders group by City order by total desc;


-- 7️.Monthly revenue
-- Group revenue by YEAR-MONTH from OrderDate.
select year(OrderDate) as 'year_',month(OrderDate) as 'month_',sum(TotalAmount) as 'total' from orders group by year_,month_ order by year_,month_




-- 8️.Average review score per category (only if Reviews > 1000)
-- Filter rows with Reviews > 1000, then group
select Category,avg(Reviews) as 'avg' from (
select * from orders where Reviews > 1000)t group by Category

-- or 

 SELECT Category,
       AVG(Reviews) AS avg_reviews
FROM orders
WHERE Reviews > 1000
GROUP BY Category;

SELECT a.Category, b.total
FROM (
    SELECT Category, SUM(TotalAmount) total
    FROM orders
    GROUP BY Category
) a
JOIN (
    SELECT Category, AVG(Rating) avg_rating
    FROM orders
    GROUP BY Category
) b
ON a.Category = b.Category;


-- 9️⃣ Find products with rating below 2
-- Show low performing products.
select * from orders where Rating<2 ORDER BY Rating ASC;


-- 🔟 Total quantity sold per brand
-- SUM(Quantity) grouped by Brand.
with temp1 as (
select  Brand,sum(Quantity) as 'total_quantity',count(Brand) as 'total' from orders group by Brand 
)
select * from temp1;


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- ADVANCED QUESTIONS (Use Window, CASE, CTE)
-- 1️.Best-selling product per category (Window + Rank)
-- For each Category, find the product with the highest total sales.

with temp1 as (
select Category,product,sum(TotalAmount) as 'total' from orders group  by Category,product
),
temp2 as (
select *,ROW_NUMBER() over(partition by Category order by total desc) as rank_
from temp1
)
select Category,product,total from temp2 where rank_=1;


-- 2️.Revenue contribution % of each category
-- CategoryRevenue / TotalRevenue * 100

with temp1 as(
select Category,sum(TotalAmount) as 'total_' from orders group  by Category
),
temp2 as (
select Category,round(((total_*100)/sum(total_) over()),2)  as 'percentage' from temp1
)
select * from temp2;

-- 3️.Top 3 cities by revenue for each platform
-- ROW_NUMBER() partitioned by Platform ordered by revenue.

with temp1 as (
select City,Platform,sum(TotalAmount) as 'total' from orders group by City,Platform
)
,temp2 as (
select * , row_number() over(partition by City order by total desc) as rank_ from temp1
)
select * from temp2 where rank_<=3

-- 4️.Repeat buyer indicator
-- Mark a city as 'High Demand' if it has > 500 total orders, else 'Normal'.
-- (Use CASE)

with temp1 as (
select City,sum(Quantity) as 'total' from orders group by City
),temp2 as (
select *,
		case
			when total > 500 then 'high_demand'
			else 'normal'
		end as 'total_order'
from temp1

)
select * from temp2 




-- 5️.Average order value per platform
-- TotalAmount / number of orders.
select * from orders
with temp1 as(
select Platform,round(avg(TotalAmount),2) as avg_amount,sum(Quantity) as 'orders_' from orders group by Platform
),
temp2 AS (
select *,round((avg_amount/orders_),2) as 'value_per_platform'
from temp1
)
select * from temp2


-- 6️.Find products priced above category average
-- Compare Price with AVG(Price) OVER (PARTITION BY Category).


WITH product_sales AS (
    SELECT
        Category,
        product,
        SUM(TotalAmount) AS total_sales
    FROM orders
    GROUP BY Category, product
)
SELECT *
FROM (
    SELECT
        *,
        AVG(total_sales) OVER (PARTITION BY Category) AS category_avg
    FROM product_sales
) t
WHERE total_sales > category_avg;




-- 7️.Median rating per category (approx using window)
-- Use window + percent_rank().
WITH ranked_ratings AS (
    SELECT
        Category,
        Rating,
        PERCENT_RANK() OVER (
            PARTITION BY Category
            ORDER BY Rating
        ) AS pr
    FROM orders
    WHERE Rating IS NOT NULL
)
SELECT
    Category,
    AVG(Rating) AS median_rating
FROM ranked_ratings
WHERE pr BETWEEN 0.49 AND 0.51
GROUP BY Category;


-- 8️.Orders per weekday
-- Extract DAYNAME from OrderDate and count.

select dayname(OrderDate) as dayname_,count(*) as total_order from orders group by dayname_


-- 9️.Running total revenue
-- Cumulative SUM(TotalAmount) ordered by OrderDate.
WITH daily_sales AS (
    SELECT
        OrderDate,
        SUM(TotalAmount) AS daily_total
    FROM orders
    GROUP BY OrderDate
)
SELECT
    OrderDate,
    daily_total,
    SUM(daily_total) OVER (
        ORDER BY OrderDate
    ) AS running_total_revenue
FROM daily_sales
ORDER BY OrderDate;


-- 10.Most reviewed brand in each category
-- Rank brands by SUM(Reviews) within each Category.
WITH brand_reviews AS (
    SELECT
        Category,
        Brand,
        SUM(Reviews) AS total_reviews
    FROM orders
    GROUP BY Category, Brand
),
ranked_brands AS (
    SELECT
        *,
        RANK() OVER (
            PARTITION BY Category
            ORDER BY total_reviews DESC
        ) AS rank_
    FROM brand_reviews
)
SELECT
    Category,
    Brand,
    total_reviews
FROM ranked_brands
WHERE rank_ = 1;


-- ---------------------------------------------------------------------------------------------------------------------------------------

-- HARD / INTERVIEW-LEVEL QUESTIONS (CTE + Subqueries + Analytics)

-- 1️.Category leader stability
-- Find categories where the SAME brand had the highest revenue
-- for at least 6 different months.
with temp1 as(
select Category,Brand,concat(year(OrderDate),'_',month(OrderDate)) as 'month_',sum(TotalAmount) as 'total' from orders group by Category,Brand,month_ 
)
,temp2 as(
select *,rank() over(partition by Category,month_ order by total desc) as ran
from temp1
),temp3 as (
select Category,Brand,count(*) as count_ from temp2 where ran=1 group by Category,Brand
)
select Category,Brand from temp3 where count_>=6



-- 2️.Profitability index
-- Define:
--    Profitability = TotalAmount / Reviews
-- Find top 10 products with highest profitability index
-- (min 100 reviews).

with temp1 as (
select Product,sum(TotalAmount) as total,sum(Reviews) as 'total_reviews' from orders group by product having total_re> 100
),temp2 as (
select *,round((total / nullif(total_reviews,0)),2) as 'Profitability' from temp1 
)
select * from temp2 order by Profitability desc limit 10
