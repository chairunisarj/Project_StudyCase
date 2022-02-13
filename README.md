# Project_StudyCase - Danny's Diner

Thank you Danny Ma for creating the challenge.  
It really helps me to brushed my skills. When I first read about this challenge, I tried to solve it immediately.  
Then I realized that I don't quite understand which SQL function to use.  
Until I read the conclusion part where Danny explained SQL functions this challenge covered, which are:  
* `Common Table Expressions`  
* `Group by Aggregates`  
* `Windows Functions for Ranking`  
* `Table Joins`  

Oh it makes me thrilled.. 😊  
Next thing was I learned about those function then come back to this case study to solve this challenge.

This post is divided into several section:  
- [Introduction](https://github.com/chairunisarj/Project_StudyCase-DannysDiner#introduction)
- [Problem Statement](https://github.com/chairunisarj/Project_StudyCase-DannysDiner#problem-statement)
- [Example Datasets](https://github.com/chairunisarj/Project_StudyCase-DannysDiner#example-datasets)
- [Case Study Questions](https://github.com/chairunisarj/Project_StudyCase-DannysDiner#case-study-questions)
- [Summary](https://github.com/chairunisarj/Project_StudyCase-DannysDiner#summary)

If you're interested to try it, you can find it in [here](https://8weeksqlchallenge.com/case-study-1/)

![](https://github.com/chairunisarj/Project_StudyCase/blob/main/images/Dannys%20Diner%20image.png)

### Introduction  

Danny seriously loves Japanese food so in the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen.

Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business.

### Problem Statement

Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.

He plans on using these insights to help him decide whether he should expand the existing customer loyalty program - additionally he needs help to generate some basic datasets so his team can easily inspect the data without needing to use SQL.

Danny has provided you with a sample of his overall customer data due to privacy issues - but he hopes that these examples are enough for you to write fully functioning SQL queries to help him answer his questions!

Danny has shared with you 3 key datasets for this case study:  
* `sales`  
* `menu`  
* `members`

You can inspect the entity relationship diagram and example data below.

![](https://github.com/chairunisarj/Project_StudyCase/blob/main/images/ERD%20Dannys%20Diner.jpg)

### Example Datasets

All datasets exist within the `dannys_diner` database schema - be sure to include this reference within your SQL scripts as you start exploring the data and answering the case study questions.

#### Table 1: sales

The `sales` table captures all `customer_id` level purchases with an corresponding `order_date` and `product_id` information for when and what menu items were ordered.

|customer_id|order_date|product_id
|-----------|----------|----------
|A|2021-01-01|1
|A|2021-01-01|2
|A|2021-01-07|2
|A|2021-01-10|3
|A|2021-01-11|3
|A|2021-01-11|3
|B|2021-01-01|2
|B|2021-01-02|2
|B|2021-01-04|1
|B|2021-01-11|1
|B|2021-01-16|3
|B|2021-02-01|3
|C|2021-01-01|3
|C|2021-01-01|3
|C|2021-01-07|3


#### Table 2: menu

The `menu` table maps the `product_id` to the actual `product_name` and price of each `menu` item.

|product_id|product_name|price
|----------|------------|-----
|1|sushi|10
|2|curry|15
|3|ramen|12

#### Table 3: members

The final `members` table captures the `join_date` when a `customer_id` joined the beta version of the Danny’s Diner loyalty program.

|customer_id | join_date
|------------|----------
|A|2021-01-07
|B|2021-01-09

### Case Study Questions

Each of the following case study questions can be answered using a single SQL statement:  

**1. What is the total amount each customer spent at the restaurant?**  
We will calculate all sales each customer spent. And because the price information is in menu table, we have to join the sales table and menu table.  
```SQL
SELECT s.customer_id, SUM(m.price) as total_spent
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
GROUP BY s.customer_id;
```  
![](https://github.com/chairunisarj/Project_StudyCase/blob/main/images/answer%20no%201.png)

**2. How many days has each customer visited the restaurant?**  
We will count how many times each customer visit with the **COUNT** function and because the question is 'how many days' we will count several visit at same day as one visit. So, we add **DISTICNT** function after the **COUNT**.  
```SQL
SELECT customer_id, COUNT(DISTINCT order_date) as times_visit
FROM sales
GROUP BY customer_id;
```  
![](https://github.com/chairunisarj/Project_StudyCase/blob/main/images/answer%20no%202.png)

**3. What was the first item from the menu purchased by each customer?**  
First we will list all items purchased by each customer chronologically (ORDER BY order_date).  To make it easier for us to find it, we add the RANK for the first time each customer visit and because it's possible that they ordered more than one menu, we user DENSE_RANK. After that we use the rank to filter it.  
```SQL
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
```  
![](https://github.com/chairunisarj/Project_StudyCase/blob/main/images/answer%20no%203.png) 

**4. What is the most purchased item on the menu and how many times was it purchased by all customers?**  
We count how many times each item was purchased, order it from the most to least. Then limit it for the most occurences.  
```SQL
SELECT TOP 1 (COUNT(s.product_id)) as MostPurchased, product_name
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
GROUP BY product_name
ORDER BY MostPurchased DESC;
```  
![](https://github.com/chairunisarj/Project_StudyCase/blob/main/images/answer%20no%204.png)  

**5. Which item was the most popular for each customer?**  
```SQL
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
```  
![](https://github.com/chairunisarj/Project_StudyCase/blob/main/images/answer%20no%205.png)

**6. Which item was purchased first by the customer after they became a member?**  
```SQL
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
```  
![](https://github.com/chairunisarj/Project_StudyCase/blob/main/images/answer%20no%206.png)  

**7. Which item was purchased just before the customer became a member?**  
```SQL
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
```  
![](https://github.com/chairunisarj/Project_StudyCase/blob/main/images/answer%20no%207.png)

**8. What is the total items and amount spent for each member before they became a member?**  
```SQL
SELECT m.customer_id, COUNT(s.product_id) as total_items,
SUM(menu.price) as total_spent
FROM members m
JOIN sales s
ON m.customer_id = s.customer_id
JOIN menu
ON s.product_id = menu.product_id
WHERE s.order_date < m.join_date
GROUP BY m.customer_id;
```  
![](https://github.com/chairunisarj/Project_StudyCase/blob/main/images/answer%20no%208.png)  

**9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?**  
```SQL
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
```  
![](https://github.com/chairunisarj/Project_StudyCase/blob/main/images/answer%20no%209.png)  

**10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?**  
```SQL
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
```  
![](https://github.com/chairunisarj/Project_StudyCase/blob/main/images/answer%20no%2010.png)

### Bonus Questions

#### Join All The Things

The following questions are related creating basic data tables that Danny and his team can use to quickly derive insights without needing to join the underlying tables using SQL.

Recreate the following table output using the available data:

|customer_id|order_date|product_name|price|member
|-----------|----------|----------|-------|-----
|A|2021-01-01|curry|15|N
|A|2021-01-01|sushi|10|N
|A|2021-01-07|curry|15|Y
|A|2021-01-10|ramen|12|Y
|A|2021-01-11|ramen|12|Y
|A|2021-01-11|ramen|12|Y
|B|2021-01-01|curry|15|N
|B|2021-01-02|curry|15|N
|B|2021-01-04|sushi|10|N
|B|2021-01-11|sushi|10|Y
|B|2021-01-16|ramen|12|Y
|B|2021-02-01|ramen|12|Y
|C|2021-01-01|ramen|12|N
|C|2021-01-01|ramen|12|N
|C|2021-01-07|ramen|12|N  

We can recreate the table using **LEFT JOIN** and **CASE** statement like this:  
```SQL
SELECT s.customer_id, s.order_date, menu.product_name, menu.price,
CASE WHEN s.order_date >= m.join_date THEN 'Y'
ELSE 'N' END as member
FROM sales s
LEFT JOIN menu
ON s.product_id = menu.product_id
LEFT JOIN members m
ON s.customer_id = m.customer_id
ORDER BY s.customer_id;
```  

#### Rank All The Things

Danny also requires further information about the `ranking` of customer products, but he purposely does not need the `ranking` for non-member purchases so he expects null ranking values for the records when customers are not yet part of the loyalty program.

|customer_id|order_date|product_name|price|member|ranking
|-----------|----------|----------|-------|-----|--------
|A|2021-01-01|curry|15|N|null
|A|2021-01-01|sushi|10|N|null
|A|2021-01-07|curry|15|Y|1
|A|2021-01-10|ramen|12|Y|2
|A|2021-01-11|ramen|12|Y|3
|A|2021-01-11|ramen|12|Y|3
|B|2021-01-01|curry|15|N|null
|B|2021-01-02|curry|15|N|null
|B|2021-01-04|sushi|10|N|null
|B|2021-01-11|sushi|10|Y|1
|B|2021-01-16|ramen|12|Y|2
|B|2021-02-01|ramen|12|Y|3
|C|2021-01-01|ramen|12|N|null
|C|2021-01-01|ramen|12|N|null
|C|2021-01-07|ramen|12|N|null  

Tor create this table we still use *JOIN* and *CASE* statement. The difference is this time we also have to use **CTE** :  
```SQL
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
```  

## Summary

From these data, we get several insights:  
1. From January, 1 2021 until February 1, 2021 there are 12 visits with total sales $186 or average $15.5 per visit.  
2. The most purchased item on the menu is ramen. Each customer has purchased it at least two times.  
3. There's a customer who doesn't become a member.  

A few things to consider:  
1. Since the favorite menu is ramen. Danny can considers to create more various menu of ramen.  
2. Promotion for member that will attract customer to convert.  
3. Bundling menu, member discount and/or redeem points can be considered to increase sales amount per visit.  
