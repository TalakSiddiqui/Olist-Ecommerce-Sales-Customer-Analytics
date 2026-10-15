SELECT * FROM ecommerce.order_items;
 
#  # “Are there duplicate combinations of order_id and order_item_id?”
select order_id, order_item_id , count(*) as duplicate_count from order_items group by order_id, order_item_id having count(*) > 1

# “Find all order items whose price is higher than the average order-item price.”
select order_id, price  from order_items where price > (select avg(price) as avg_order_price from order_items ) 


b