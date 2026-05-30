--продажи по дням
create or replace view salesbyday as
with returns_agg as (
    select
        order_item_id,
        sum(return_amount) as return_amount
    from returns
    group by order_item_id
)
select 
    o.order_date::date as date,
    sum(oi.quantity * oi.price) 
        - coalesce(sum(r.return_amount), 0) as revenue,
    count(distinct o.order_id) as orders_cnt
from orders o
join order_items oi using (order_id)
left join returns_agg r using (order_item_id)
where o.status <> 'cancelled'
group by o.order_date::date
order by date desc;

select * from SalesByDay;

--кто приности нам деньги и сколько
create or replace view salesbycustomers as
select 
    customer_id,
    sum(total_rev - coalesce(returned, 0)) as total_revenue,
    count(distinct order_id) as orders_cnt,
    avg(total_rev - coalesce(returned, 0)) as avg_check,
    min(order_date)::date as first_order,
    max(order_date)::date as last_order
from (
    select 
        o.customer_id,
        o.order_id,
        sum(oi.price * oi.quantity) as total_rev,
        coalesce(sum(r.return_amount), 0) as returned,
		order_date
    from orders o
    join order_items oi using (order_id)
    left join returns r using (order_item_id)
    where o.status <> 'cancelled'
    group by o.customer_id, o.order_id, order_date
) t
group by customer_id
order by total_revenue desc;

select * from salesbycustomers;

--какие товары приносят деньги и сколько их покупают
create view ProductsSold as
with t as (select 
	product_id,
	product_name,
	sum (oi.quantity) as total_sold,
	sum (oi.quantity * oi.price) as profit,
	count (distinct o.order_id) as orders_cnt
from order_items oi
join orders o using (order_id)
join products p using (product_id)
where o.status <> 'cancelled'
group by product_id, product_name)
select 
	product_id,
	product_name,
	total_sold,
	profit - coalesce (return_amount, 0) as revenue,
	orders_cnt
from t
left join (
	select 
		product_id,
		sum (return_amount) as return_amount
	from returns 
	join order_items using (order_item_id)
	group by product_id)
using (product_id);

select * from ProductsSold;