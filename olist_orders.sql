SELECT * FROM ecommerce.orders;
SELECT COUNT(*) AS total_orders FROM orders;

# "Show each order along with the customer's city and the product purchased."
select o.order_id, c.customer_city, oi.product_id from orders o join customers c on o.customer_id = c.customer_id
join order_items oi on o.order_id = oi.order_id

# "Classify each order based on its current status."
# "Classify each order based on its delivery status."
SELECT order_id,
    order_status,
    CASE
        WHEN order_status = 'delivered' THEN 'Delivered'
        WHEN order_status = 'shipped' THEN 'In Transit'
        WHEN order_status = 'canceled' THEN 'Cancelled'
        WHEN order_status = 'processing' THEN 'Processing'
        ELSE 'Other'
    END AS delivery_category FROM orders;

# "Find the average product price first, then show all order items whose price is higher than that average."
With average_price as 
           (select avg(price) as AVG_PRICE from order_items)
select oi.product_id, oi.price from order_items oi
           cross join average_price ap  
      where oi.price > ap.avg_price

# For each customer, calculate how many orders they have placed, and show only customers who placed more than 1 order."

WITH CUSTOMER_ORDERS AS
 (SELECT CUSTOMER_ID, COUNT(*) AS TOTAL_ORDERS FROM ORDERS GROUP BY CUSTOMER_ID)
SELECT CUSTOMER_ID, TOTAL_ORDERS FROM CUSTOMER_ORDERS
WHERE TOTAL_ORDERS > 1 

WITH customer_orders AS (
    SELECT 
        customer_id,
        COUNT(*) AS total_orders FROM orders
        GROUP BY customer_id
)SELECT
    customer_id,total_orders
FROM customer_orders WHERE total_orders > 1;
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# "Find the number of orders for each order status, then show only statuses with more than 10 orders."
with order_summary as 
(select order_status , count(*) as total_orders from orders group by order_status)
select order_status,total_orders from order_summary where total_orders > 10

# "Find the top 5 customers based on the number of orders they placed."
with customer_orders as (
 select  customer_id, count(*) as total_orders from orders group by customer_id)
 select customer_id, total_orders from customer_orders order by total_orders desc limit 5

# "How many orders are Delivered vs other statuses?"
with order_status_cheaked as 
     (select customer_id , order_status, 
    case 
    when order_status = 'delivered' then 'order delivered'
    when order_status = 'cancelled' then 'not delivered'
    else 'other'
    end as delivered_status 
    from orders )
select * from order_status_cheaked
---------------------------------------------------------------------------------------------------------------------------------------------------------------
# “Which year was each order placed?”
SELECT ORDER_ID,YEAR(order_purchase_timestamp) AS ORDER_PLACED FROM ORDERS
# “Which month was each order placed?”
SELECT ORDER_ID, order_purchase_timestamp, MONTH(order_purchase_timestamp) AS ORDER_PLACED FROM ORDERS
# “How many days did it take to deliver each order?”
SELECT ORDER_ID, DATEDIFF(order_delivered_customer_date,order_purchase_timestamp) AS DAYS_TO_DELIVERED FROM ORDERS
------------------------------------------------------------------------------------------------------------------------------------------------------------
# “Identify whether each order was delivered or not.”                   
SELECT ORDER_ID, ORDER_STATUS , IF(ORDER_STATUS = "DELIVERED",'YES','NO') AS IS_DELIVERED FROM ORDERS                        #( IF FUNCTION)             

# “Show each order's delivery date, but if the delivery date is missing, display Not Delivered instead.”
SELECT order_id, IFNULL(order_delivered_customer_date, 'Not Delivered') AS delivery_status FROM orders;

# “Find all orders whose delivery time was longer than the average delivery time.”
SELECT 
    order_id, DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) AS delivery_days FROM orders
WHERE DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) > (
    SELECT AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp))FROM orders);
-----------------------------------------------------------------------------------------------------------------------------------------------------------
# “Find customers who placed order more than the average customer.”
select round(avg(total_orders),2) AS CUSTOMER_ORDERS from 
(select  customer_id, count(*) as total_orders from orders group by customer_id ) as customer_orders (
SELECT ORDER_ID,CUSTOMER_ID, COUNT(*) AS CUSTOMER_TOTAL_ORDER FROM ORDERS GROUP BY CUSTOMER_ID )             

------------------------------------------------------------------------------------------------------------------------------------------------------------
# “Rank each customer's orders in chronological order, so we can identify their 1st, 2nd, 3rd order, etc.”
select customer_id, order_id, 
row_number() over (partition by customer_id order by order_purchase_timestamp asc) as order_number from orders

# “Rank customers based on the number of orders they placed.”
select customer_id , COUNT(*) AS total_orders ,
rank() over (order by  COUNT(*) desc) as cust_ranked from orders group by customer_id
----------------------------------------------------------------------------------------------------------------------------------------------------------
# “Rank customers by the number of orders they placed, without skipping rank numbers when two customers have the same number of orders
select customer_id, count(*) as total_orders ,
rank() over (order by count(*) desc) as customer_rank,
dense_rank() over (order by count(*) desc ) as number_of_orders
from orders group by customer_id
------------------------------------------------------------------------------------------------------------------------------------------------------------
# “For each customer, show their current order date and the date of their previous order.”
select customer_id, order_id, date(order_purchase_timestamp) as order_date,
lag(date(order_purchase_timestamp)) over 
(partition  by customer_id order by order_purchase_timestamp) 
as previous_order_date from orders

# “For each customer, show their current order date and their next order date.”
select customer_id, order_id, date(order_purchase_timestamp) as order_date,
lead(date(order_purchase_timestamp)) over (partition by customer_id order by order_purchase_timestamp)
 as next_order_date from orders

# “How does cumulative sales/revenue grow over time?” 
SELECT
    oi.order_id, oi.price, SUM(oi.price) OVER (
	ORDER BY o.order_purchase_timestamp) AS running_total
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id;

 # “Are there different spellings/cases of the same order status?”
 select distinct(order_status) from orders
 select  count(*) from orders where order_status is null
 
 # “Are there any orders where the delivery date is earlier than the purchase date?”
 select count(*)  as invalid_dates 
 from orders where order_delivered_customer_date >  order_purchase_timestamp
 
 # “How many orders are missing their approval date?”
 select count(*) as missing_order from orders where order_approved_at  is null
 
# “Who are the top 5 customers based on the number of orders they placed?”
select customer_id, count(*) as total_orders from orders group by customer_id order by total_orders desc limit 5 

# “Show each order along with the customer’s city and state.”
select o.order_id, c.customer_city, c.customer_state from orders o inner join customers c on o.customer_id = c.customer_id  

# “For each customer, rank their orders chronologically — 1st order, 2nd order, 3rd order, etc.”
select customer_id , order_id,
row_number() over (partition by customer_id order by order_purchase_timestamp asc) as order_rank
from orders 

# “For each customer, show their current order date and the date of their previous order.”
select customer_id, order_id, order_purchase_timestamp as order_date,
lag(order_purchase_timestamp) over (partition by customer_id order by order_purchase_timestamp asc) as previous_order_date
from orders

# “For each customer, calculate their total number of orders and total sales, and show only customers who placed more than 1 order.”
select c.customer_id , 
       count(distinct o.order_id) as total_orders, 
              sum(oi.price) as total_sales from customers c 
join orders o on c.customer_id = o.customer_id
       join order_items oi on o.order_id = oi.order_id 
	      group by c.customer_id 
                having count(distinct o.order_id) > 1
===========================================================================================================================================================================================================================================




