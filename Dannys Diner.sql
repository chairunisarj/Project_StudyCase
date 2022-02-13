CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');

  CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

--- CASE STUDY QUESTIONS ---

-- 1. What is the total amount each customer spent at the restaurant?
-- We will calculate all sales each customer spent. And because the price information is in menu table, we have to join the sales table and menu table.

SELECT s.customer_id, SUM(m.price) as total_spent
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
GROUP BY s.customer_id;

-- 2. How many days has each customer visited the restaurant?
-- we will count how many times each customer visit with the COUNT function and because the question is 'how many days' we will count several visit at same day as one visit. So, we add DISTICNT function after the COUNT. 

SELECT customer_id, COUNT(DISTINCT order_date) as times_visit
FROM sales
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?
-- First we will list all items purchased by each customer chronologically (ORDER BY order_date).  To make it easier for us to find it, we add the RANK for the first time each customer visit and because it's possible that they ordered more than one menu, we user DENSE_RANK. After that we use the rank to filter it.

WITH CTE_visit as
(
SELECT customer_id, order_date, product_name,
DENSE_RANK () OVER (PARTITION BY customer_id ORDER BY order_date) as rank
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
GROUP BY customer_id, order_date, product_name
)
SELECT customer_id, product_name
FROM CTE_visit
WHERE rank = 1;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- We count how many times each item was purchased, order it from the most to least. Then limit it for the most occurences.

SELECT TOP 1 (COUNT(s.product_id)) as MostPurchased, product_name
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
GROUP BY product_name
ORDER BY MostPurchased DESC;



-- 5. Which item was the most popular for each customer?

WITH CTE_popular as
(
SELECT s.customer_id, m.product_name,
COUNT(s.product_id) as order_count,
DENSE_RANK () OVER (PARTITION BY customer_id ORDER BY COUNT(s.product_id) DESC) as rank
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
GROUP BY s.customer_id, product_name
)
SELECT customer_id, product_name, order_count
FROM CTE_popular
WHERE rank = 1;



-- 6. Which item was purchased first by the customer after they became a member?

WITH CTE_aftermember as
(
SELECT s.customer_id, menu.product_name, s.order_date, m.join_date,
DENSE_RANK () OVER (PARTITION BY s.customer_id ORDER BY s.order_date ) as rank
FROM sales s
JOIN members m
ON s.customer_id = m.customer_id
JOIN menu
ON s.product_id = menu.product_id
WHERE s.order_date >= m.join_date
GROUP BY s.customer_id, menu.product_name, s.order_date, m.join_date
)
SELECT customer_id, product_name
FROM CTE_aftermember
WHERE rank = 1;



-- 7. Which item was purchased just before the customer became a member?

WITH CTE_beforemember as
(
SELECT s.customer_id, menu.product_name, s.order_date, m.join_date,
DENSE_RANK () OVER (PARTITION BY s.customer_id ORDER BY s.order_date DESC) as rank
FROM sales s
JOIN members m
ON s.customer_id = m.customer_id
JOIN menu
ON s.product_id = menu.product_id
WHERE s.order_date < m.join_date
GROUP BY s.customer_id, menu.product_name, s.order_date, m.join_date
)
SELECT customer_id, product_name
FROM CTE_beforemember
WHERE rank = 1;



-- 8. What is the total items and amount spent for each member before they became a member?

SELECT m.customer_id, COUNT(s.product_id) as total_items,
SUM(menu.price) as total_spent
FROM members m
JOIN sales s
ON m.customer_id = s.customer_id
JOIN menu
ON s.product_id = menu.product_id
WHERE s.order_date < m.join_date
GROUP BY m.customer_id;

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

WITH CTE_points AS
(
SELECT *,
CASE WHEN product_id = 1 THEN price * 20
ELSE price * 10 END as points
FROM menu
)
SELECT s.customer_id, SUM(p.points) as total_points
FROM sales s
JOIN CTE_points p
ON s.product_id = p.product_id
GROUP BY s.customer_id;



-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

WITH allpoints AS
(
SELECT s.customer_id, s.order_date, m.join_date,
CASE WHEN s.order_date >= m.join_date AND s.order_date <= DATEADD(DAY, 6, m.join_date) THEN menu.price * 20
	WHEN s.order_date > DATEADD(DAY, 6, m.join_date) AND menu.product_name = 'sushi' THEN menu.price * 20
	WHEN s.order_date > DATEADD(DAY, 6, m.join_date) AND menu.product_name != 'sushi' THEN menu.price * 10
   END as points
FROM sales s
JOIN members m
ON s.customer_id = m.customer_id
JOIN menu
ON s.product_id = menu.product_id
)
SELECT customer_id, SUM(points) as total_points
FROM allpoints
WHERE order_date <= ('2021-01-31')
GROUP BY customer_id;


---- BONUS QUESTION

---- RECREATE THE TABLE

SELECT s.customer_id, s.order_date, menu.product_name, menu.price,
CASE WHEN s.order_date >= m.join_date THEN 'Y'
ELSE 'N' END as member
FROM sales s
LEFT JOIN menu
ON s.product_id = menu.product_id
LEFT JOIN members m
ON s.customer_id = m.customer_id
ORDER BY s.customer_id;


---- RANK ALL THE THINGS

WITH allranks AS
(
SELECT s.customer_id, s.order_date, menu.product_name, menu.price,
CASE WHEN s.order_date >= m.join_date THEN 'Y'
ELSE 'N' END as member
FROM sales s
LEFT JOIN menu
ON s.product_id = menu.product_id
LEFT JOIN members m
ON s.customer_id = m.customer_id
)
SELECT *,
CASE WHEN member = 'N' THEN Null
ELSE 
RANK () OVER (PARTITION BY customer_id, member ORDER BY order_date)
END as rank
FROM allranks
ORDER BY customer_id;

