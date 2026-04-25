with t as (select 
	order_date,
	sum(profit - coalesce (returned,0)) as revenue
from 
(select 
		oi.order_item_id,
		o.order_date::date,
		oi.quantity * oi.price as profit
	from orders o
	join order_items oi
	using (order_id)
	where o.status <> 'cancelled') t
left join
(select
	order_item_id,
	sum (return_quantity * return_amount) as returned
from returns
group by order_item_id) b
using (order_item_id)
group by order_date)
select
	*,
	lag (revenue) over (order by order_date) as prev_revenue,
	revenue - lag (revenue) over (order by order_date) as diff
from t;

--2
with t as (
    select 
        oi.product_id,
        p.product_name,
        sum(oi.quantity) as total_sold,
        sum(oi.quantity * oi.price) as profit
    from order_items oi
    join orders o using (order_id)
    join products p using (product_id)
    where o.status <> 'cancelled'
    group by oi.product_id, p.product_name
),
final as (
    select 
        t.product_id,
        t.product_name,
        total_sold,
        profit - coalesce(r.return_amount, 0) as revenue,
        rank() over (order by profit - coalesce(r.return_amount, 0) desc) as rank
    from t
    left join (
        select 
            oi.product_id,
            sum(r.return_amount) as return_amount
        from returns r
        join order_items oi using (order_item_id)
        group by oi.product_id
    ) r using (product_id)
)
select 
    *,
    round(revenue / sum(revenue) over () * 100, 2) as revenue_share
from final
where rank <= 5;

	
