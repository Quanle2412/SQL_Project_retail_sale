-- SQL Retail Sales Analysis - P1
-- CREATE DATABASE
CREATE DATABASE sql_project_p2;
-- Create table
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales 
			(
				transactions_id	INT primary key,
				sale_date	DATE,
				sale_time	TIME,
				customer_id	INT,
				gender	VARCHAR(15),
				age	INT,
				category VARCHAR(15),	
				quantity	INT,
				price_per_unit	FLOAT,
				cogs	FLOAT,
				total_sale FLOAT
				);
-- Show 10 rows
SELECT *
FROM retail_sales
LIMIT 10

-- Count the total of records
SELECT count(*)
FROM retail_sales

-- Kiểm tra có transaction_id nào NULL không
SELECT *
FROM retail_sales
WHERE transactions_id IS NULL

SELECT *
FROM retail_sales
WHERE sale_date IS NULL

-- DATA CLEANING
-- Viết 1 hàm kiểm tra có cột nào có giá trị NULL không với OR
SELECT *
FROM retail_sales
WHERE 
	transactions_id IS NULL
	OR
	sale_date IS NULL
	OR
	sale_time IS NULL
	OR
	customer_id IS NULL
	OR
	gender IS NULL
	OR
	category IS NULL
	OR
	quantity IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL;
-- Xóa các records có giá trị NULL
DELETE FROM retail_sales
WHERE 
	transactions_id IS NULL
	OR
	sale_date IS NULL
	OR
	sale_time IS NULL
	OR
	customer_id IS NULL
	OR
	gender IS NULL
	OR
	category IS NULL
	OR
	quantity IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL;


-- DATA EXPLORATION (Khám phá dữ liệu)
-- 1. How many customers we have?
SELECT distinct count(customer_id)
FROM retail_sales
-- 2. How many categories we have?
SELECT distinct category
FROM retail_sales


-- DATA ANALYSIS & BUSINESS KEY PROBLEMS & ANSWERS

-- MY ANALYSIS & FINDINGS
-- Q.1. Write a SQL query to retrieve all columns for sales made on "2022-11-05"
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';
-- Q.2. Write a SQL query to retrieve all transactions where the category is "Clothing" and the quantity sold is more than 4 in the month of Nov-22
SELECT *
FROM retail_sales
WHERE category='Clothing' 
	and  to_char(sale_date, 'YYYY-MM')= '2022-11' 	-- syntax: to_char(values, format): chuyển thành chuỗi với định dạng mong muốn.
	and quantity >=4

-- Q.3. Write a SQL query to calculate the total sales (total_sale) for each category
SELECT category, gender, sum(total_sale) total_order
FROM retail_sales
Group by 1, 2
Order by 1,2;
-- Q.4. Write a sQL query to find the average age of customers who purchased items from the "Beauty" category
SELECT category, round(avg(age),2) as avg_age
FROM retail_sales
Group by 1;

-- Q.5. Write a SQL query to find all transactions where the total_sale is greater than 1000
SELECT *
FROM retail_sales
WHERE total_sale>=1000;
-- Q.6. Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category
SELECT gender, category, count(transactions_id) as total_number_of_transactions
FROM retail_sales
GROUP BY 1,2;

-- Q.7. Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
-- Option_01: use ORDER BY
SELECT
	EXTRACT (YEAR FROM sale_date) as year,
	EXTRACT (MONTH FROM sale_date) as month,
	avg(total_sale) as avg_total_sales
FROM retail_sales
GROUP BY 1,2
ORDER BY 1 DESC,2 DESC;

-- Option_02: use RANK()
SELECT
	EXTRACT (YEAR FROM sale_date) as year,
	EXTRACT (MONTH FROM sale_date) as month,
	avg(total_sale) as avg_total_sale,
	RANK() OVER (PARTITION BY EXTRACT (YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) -- Xếp hạng dựa trên sự phân chia theo năm, theo thứ tự giảm dần mức total_sale trung bình
FROM retail_sales
GROUP BY 1,2;
-- Chọn rank 1
SELECT * FROM(
	SELECT
		EXTRACT (YEAR FROM sale_date) as year,
		EXTRACT (MONTH FROM sale_date) as month,
		avg(total_sale) as avg_total_sale,
		RANK() OVER (PARTITION BY EXTRACT (YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) -- Xếp hạng dựa trên sự phân chia theo năm, theo thứ tự giảm dần mức total_sale trung bình
	FROM retail_sales
	GROUP BY 1,2
)as table_01
WHERE rank=1
-- Q.8. Write a SQL query to find the top 5 customers based on the highest total sales
SELECT 
	customer_id , 
	SUM(total_sale) as total,
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

--Option_02: Sử dụng thêm xếp hàng RANK()
SELECT 
    customer_id, 
    SUM(total_sale) AS total,
    RANK() OVER (ORDER BY SUM(total_sale) DESC) AS rank
FROM retail_sales
GROUP BY customer_id
LIMIT 5;

-- THỦ nghiệm
SELECT
	customer_id,
	sum(total_sale) as total_sales,
	RANK() over (partition by customer_id order by sum(total_sale) DESC) as rank_per_customer
FROM retail_sales
GROUP BY 1;

-- Q.9.Write a SQL query to find the number of unique customers who purchased items from each category
SELECT 
	category,
	count(distinct customer_id) as the_number_of_unique_customer
FROM retail_sales
Group by category;

-- Q.10. Write a SQL query to create each shift and number of orders (Example Morning<=12, Afternoon Between 12 & 17, Evening >17)
-- Sử dụng CASE WHEN ELSE END

WITH hourly_sale
AS
(SELECT *, 
	CASE
		WHEN EXTRACT(HOUR FROM sale_time) <= 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM sale_time) between 12 and 17 THEN 'Afternoon'
		ELSE 'Evening'
	END as shift
FROM retail_sales)

SELECT shift, count(transactions_id) as num_of_orders
FROM hourly_sale
Group by shift

-- END OF PROJECT


