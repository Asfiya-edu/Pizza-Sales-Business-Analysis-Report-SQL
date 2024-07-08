--1) Retrieve the total number of orders placed. 
SELECT 
	COUNT(order_id) AS total_orders
 FROM [pizzasales].[dbo].[orders];

--2) Calculate the total revenue generated from pizza sales.
SELECT 
	ROUND(SUM(order_details.quantity * pizzas.price),2) AS total_sales
FROM order_details 
JOIN pizzas
ON pizzas.pizza_id = order_details.pizza_id;

--3) Identify the highest-priced pizza.
SELECT TOP (1) -- TOP (1) is used as LIMIT 1 in other sql database
	pizza_types.name, ROUND(pizzas.price, 2)
FROM pizza_types 
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC;

--4) Identify the most common pizza size ordered.
SELECT 
	pizzas.size, COUNT(order_details.order_details_id) AS order_count
FROM pizzas 
JOIN order_details ON pizzas.pizza_id = order_details.pizza_id 
GROUP BY pizzas.size 
ORDER BY order_count DESC;

--5) List the top 5 most ordered pizza types along with their quantities.
SELECT TOP(5)
	pizza_types.name,
SUM(order_details.quantity) AS quantity
FROM pizza_types 
JOIN pizzas 
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC;


--Intermediate:--
--6) Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
	pizza_types.category, SUM(order_details.quantity) AS quantity
FROM pizza_types 
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id 
GROUP BY pizza_types.category 
ORDER BY quantity DESC;

--7) Determine the distribution of orders by hour of the day.
SELECT 
	DATEPART(hour, orders.time) AS hour, COUNT(order_id) AS orders
FROM orders
GROUP BY DATEPART(hour, orders.time)
ORDER BY orders DESC; 
 
--8) Join relevant tables to find the category-wise distribution of pizzas.
SELECT category, COUNT(name) AS no_of_pizzas
FROM pizza_types 
GROUP BY category;

--9) Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT ROUND(AVG(quantity),0) AS AvgQuantityPerDay
FROM 
	(SELECT orders.date, SUM(order_details.quantity) AS quantity
		FROM orders 
		JOIN order_details
		ON orders.order_id = order_details.order_id
		GROUP BY orders.date) AS order_quantity;

--10) Determine the top 3 most ordered pizza types based on revenue.
SELECT TOP(3)
pizza_types.name , 
SUM(order_details.quantity * pizzas.price) AS revenue
FROM pizza_types 
JOIN pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name 
ORDER BY revenue DESC;

--Advanced:
-- 11) Calculate the percentage contribution of each pizza type to total revenue.
SELECT pizza_types.category,
	ROUND(SUM(order_details.quantity * pizzas.price) / 
		(SELECT ROUND(SUM(order_details.quantity * pizzas.price), 2) AS total_sales
		FROM order_details
		JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id) * 100,2) AS revenue
FROM pizza_types 
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id 
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category 
ORDER BY revenue DESC;


-- 12) Analyze the cumulative revenue generated over time.

SELECT date, 
	SUM(revenue) OVER(ORDER BY date) AS cum_revenue
FROM
	(SELECT orders.date, 
		SUM(order_details.quantity * pizzas.price) AS revenue
	FROM order_details
	JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
	JOIN orders ON orders.order_id = order_details.order_id
	GROUP BY orders.date) AS sales; 

-- 13) Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT name, revenue 
FROM
	(SELECT category, name, revenue,
		RANK() OVER(PARTITION BY category ORDER BY revenue DESC) AS rn
	FROM
		(SELECT pizza_types.category, pizza_types.name,
			SUM(order_details.quantity * pizzas.price) AS revenue
		FROM pizza_types 
		JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
		JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
		GROUP BY pizza_types.category, pizza_types.name) AS a) AS b
WHERE rn <= 3;