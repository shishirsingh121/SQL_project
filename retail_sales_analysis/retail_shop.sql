create database retail_sale;
use retail_sale;
select * from sale;

-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05'
select * from sale where sale_date='2022-11-05';


-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than or equal to 4 in the month of Nov-2022
select * from sale where category='Clothing' and quantiy>=4 and month(sale_date )=11 and year(sale_date)=2022 order by sale_date;
-- or
SELECT *
FROM sale
WHERE category = 'Clothing'
  AND quantiy >= 4
  AND sale_date BETWEEN '2022-11-01' AND '2022-11-30';

-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
select category,sum(total_sale) as 'total_sale',count(customer_id) as 'total'  from sale group by category;



-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
select avg(age) as 'avg' from sale where category='Beauty';

-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
select * from sale where total_sale>1000;




-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
select gender,count(transactions_id) as "transaction count" from sale group by gender


-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
with month_avg as (
select year(sale_date) as 'year_',month(sale_date) as 'month_',avg(total_sale) as 'avg_sale', dense_rank() over(partition by year(sale_date) order by avg(total_sale) desc )as rnk
 
from sale group by year(sale_date),month(sale_date)
)
select year_,month_,avg_sale from month_avg where rnk=1


WITH monthly_avg AS (
    SELECT 
        YEAR(sale_date)   AS year_,
        MONTH(sale_date)  AS month_,
        AVG(total_sale)   AS avg_sale,
        DENSE_RANK() OVER (
            PARTITION BY YEAR(sale_date)
            ORDER BY AVG(total_sale) DESC
        ) AS rnk
    FROM sale
    GROUP BY YEAR(sale_date), MONTH(sale_date)
)
SELECT year_, month_, avg_sale
FROM monthly_avg
WHERE rnk = 1
ORDER BY year_;




-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
select * from sale order by total_sale desc limit 5

-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
select category,count(distinct(customer_id)) as unique_customer from sale group by category

-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)
select * from sale
SELECT 
    CASE 
        WHEN HOUR(sale_time) < 12 THEN 'Morning'
        WHEN HOUR(sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS total_orders
FROM sale
GROUP BY shift
ORDER BY total_orders DESC;


