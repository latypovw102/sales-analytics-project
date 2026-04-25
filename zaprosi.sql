--выручка по месяцам
select 
	month,
	(profit - tt.returned) as total_profit
from (select 
	sum (oi.quantity * oi.price) as profit,
	to_char(o.order_date, 'TMMonth YYYY') AS month
from order_items oi
join orders o using (order_id)
where o.status <> 'cancelled'
group by month
order by month) t
left join 
(select 
	sum (r.return_amount * r.return_quantity) as returned,
	to_char (ord.order_date, 'TMMonth YYYY') as month
from returns r
join order_items using (order_item_id)
join orders ord using (order_id)
group by month) tt
using (month);

--общая выручка, количество заказов и средний чек для каждого клиента
select 
    customer_id,
    sum(total_rev - coalesce(returned, 0)) as total_revenue,
    count(distinct order_id) as orders_cnt,
    avg(total_rev - coalesce(returned, 0)) as avg_check
from (
    select 
        o.customer_id,
        o.order_id,
        sum(oi.price * oi.quantity) as total_rev,
        coalesce(sum(r.return_amount), 0) as returned
    from orders o
    join order_items oi using (order_id)
    left join returns r using (order_item_id)
    where o.status <> 'cancelled'
    group by o.customer_id, o.order_id
) t
group by customer_id
order by total_revenue desc;

--топ 3 клиента по выручке в каждом регионе 
with t as (select
	customer_id,
	sum (quantity * price) as profit,
	region_id,
	country,
	city
from orders
join order_items using (order_id)
join regions using (region_id)
where status <> 'cancelled'
group by customer_id, region_id, country, city),
ranked as (
select
	*,
	rank() over (partition by region_id order by profit desc) as rank
from t)
select * from ranked
where rank <=3

--как удерживаются пользователи после первой покупки?
with t as (
    select
        customer_id,
        to_char(min(order_date) over (partition by customer_id), 'YYYY-MM') as cohort_month,
        to_char(order_date, 'YYYY-MM') as activity_month
    from orders
    where status <> 'cancelled'
)
select
    cohort_month,
    activity_month,
    count(distinct customer_id) as users_cnt
from t
group by cohort_month, activity_month
order by cohort_month, activity_month;

--воронка продаж
select 
    'created_order' as step,
    count(*)::text as cnt
from orders
where status <> 'cancelled'
union all
select 
    'paid_order' as step,
    count(distinct o.order_id)::text as cnt
from orders o
join payments p using (order_id)
where p.status = 'success'
  and o.status <> 'cancelled'
union all
select 
    'conversion_rate' as step,
    round(
        (
            select count(distinct o.order_id)::numeric
            from orders o
            join payments p using (order_id)
            where p.status = 'success'
              and o.status <> 'cancelled'
        )
        /
        (
            select count(*)::numeric
            from orders
            where status <> 'cancelled'
        ) * 100
    , 2
    )::text || '%';


