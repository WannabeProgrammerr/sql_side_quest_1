--SQL Retail Sales Analysis - P1

--Create Table 
DROP TABLE IF EXISTS retail_sales;

CREATE TABLE retail_sales
	(transactions_id	INT PRIMARY KEY NOT NULL,
	 sale_date			DATE,
	 sale_time			TIME,
	 customer_id  		INT,
	 gender				VARCHAR(10),
	 age				INT,
	 category     		VARCHAR(15),
	 quantity			INT,
	 price_per_unit		FLOAT,
	 cogs				FLOAT,
	 total_sale			FLOAT
);

SELECT * 
FROM retail_sales
LIMIT 10;

--Total Number of Records in the Dataset. 

SELECT COUNT(*)
FROM retail_sales;

--DATA CLEANING
--To Check for NULL Values 
SELECT * 
FROM retail_sales
WHERE transactions_id  IS NULL;

SELECT * 
FROM retail_sales
WHERE sale_date IS NULL;

SELECT * 
FROM retail_sales
WHERE sale_time IS NULL;

/*Now doing this across each column where we check for NULL values across all the columns 
would be time consuming, in this case we can use the NESTED WHERE Clause.*/

SELECT * 
FROM retail_sales
WHERE transactions_id IS NULL 
	or 
	  sale_date IS NULL 
	  or 
	  sale_time IS NULL 
	  or
	  customer_id IS NULL 
	  or
	  gender IS NULL 
	  or
	  age IS NULL
	  or
	  category IS NULL 
	  or
	  quantity IS NULL 
	  or
	  price_per_unit IS NULL 
	  or
	  cogs IS NULL 
	  or
	  total_sale IS NULL;

/* Now we can either delete or replace the NULL Values. 
In this case we are deleting the NULL Values. */

DELETE FROM retail_sales
WHERE transactions_id IS NULL 
	or 
	  sale_date IS NULL 
	  or 
	  sale_time IS NULL 
	  or
	  customer_id IS NULL 
	  or
	  gender IS NULL 
	  or
	  age IS NULL
	  or
	  category IS NULL 
	  or
	  quantity IS NULL 
	  or
	  price_per_unit IS NULL 
	  or
	  cogs IS NULL 
	  or
	  total_sale IS NULL;

/* Here filtering which rows you want to delete is VERY IMPORTANT otherwise the DELETE Clause
will just delete all the rows from the table. */

--Now after deleting the NULL Values we are checking how many records we are left with.
SELECT COUNT(*)
FROM retail_sales;

--To verify if we have any more NULL Values. 
SELECT * 
FROM retail_sales
WHERE transactions_id IS NULL 
	or 
	  sale_date IS NULL 
	  or 
	  sale_time IS NULL 
	  or
	  customer_id IS NULL 
	  or
	  gender IS NULL 
	  or
	  age IS NULL
	  or
	  category IS NULL 
	  or
	  quantity IS NULL 
	  or
	  price_per_unit IS NULL 
	  or
	  cogs IS NULL 
	  or
	  total_sale IS NULL;

--Now explore the data then we can solve the business problems. 
--DATA EXPLORATION. 

--Q. How many sales do we have?
SELECT 
	COUNT(*) as total_sales
FROM retail_sales;

--Q. How many customers do we have?
SELECT * 
FROM retail_sales;

SELECT 
	COUNT(customer_id) as total_customers
FROM retail_sales;

--Q. Find how many unique customers do we have?
SELECT 
	COUNT(DISTINCT customer_id) as total_customers
FROM retail_sales;

--Q. How many categories do we have?
SELECT * 
FROM retail_sales;

SELECT 
	DISTINCT category 
FROM retail_sales;

/* Now let's do some Data Analysis or Business Key Problems and Answers. */
-- My Analysis & Findings
-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05'
	SELECT * 
	FROM retail_sales
	WHERE sale_date = '2022-11-05';
-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' 
--and the quantity sold is more than 2 in the month of Nov-2022

SELECT 
	*
FROM retail_sales
WHERE category = 'Clothing' 
	AND 
	TO_CHAR(sale_date, 'yyyy-mm') = '2022-11'
	AND 
	quantity > 2;

-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
SELECT 
	category,
	count(*) as total_orders,
	sum(total_sale) as toal_sales
FROM retail_sales
group by category;

-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.

select 
	avg(age) as average_age
from retail_sales
where category = 'Beauty';

-- Now here i want to round off to the nearest 2 decimal points for the average age. 
select 
	round(avg(age), 2) as average_age 
from retail_sales
where category = 'Beauty';

-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
select 
	* 
from retail_sales
where total_sale > 1000
order by transactions_id ASC;

-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
select 
	category, 
	gender,
	count(transactions_id)
from retail_sales
group by category, gender
order by category;
	
-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year. 
select 
	* 
from retail_sales

select *
from 
	(select 
		EXTRACT(YEAR FROM sale_date) as year, 
		EXTRACT(MONTH FROM sale_date) as month,
		avg(total_sale) as avg_sale, 
		rank() over(partition by EXTRACT(YEAR FROM sale_date)order by avg(total_sale)desc) as rank
	from retail_sales
	group by year, month) as t1
where rank = 1;

--or 
select 
	year, 
	month, 
	avg_sale
from 
	(select 
		EXTRACT(YEAR FROM sale_date) as year, 
		EXTRACT(MONTH FROM sale_date) as month,
		avg(total_sale) as avg_sale, 
		rank() over(partition by EXTRACT(YEAR FROM sale_date)order by avg(total_sale)desc) as rank
	from retail_sales
	group by year, month) as t1
where rank = 1;

-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales
select *
from retail_sales

select
	customer_id,
	sum(total_sale) as total_sales
from retail_sales
group by customer_id
order by total_sales desc
limit 5;

-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.

select *
from retail_sales

select 
	count(distinct customer_id) as unique_customers,
	category
from retail_sales
group by category;
-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <12, 
--Afternoon Between 12 & 17, Evening >17)

select *
from retail_sales

--Using an important concept of segmentation. 

with hourly_sale
as
(
select *,
	case 
		when extract(hour from sale_time) < 12 then 'Morning'
		when extract(hour from sale_time) between 12 and 17 then 'Afternoon'
		else 'Evening'
	end as shift
from retail_sales
)
select 
	shift,
	count(transactions_id) as total_orders
from hourly_sale
group by shift; 

--How to get current hour. 
select extract(hour from current_time)

--End Of Project. 
