create or replace view customer_segments_summary as
with x as (
    select
        customer_id,
        total_revenue
    from salesbycustomers
),
segmented as (
    select
        customer_id,
        total_revenue,
        case ntile(3) over (order by total_revenue desc)
            when 1 then 'vip'
            when 2 then 'middle'
            else 'low'
        end as segment
    from x
)
select
    segment,
    count(*) as customers_cnt,
    round(sum(total_revenue), 2) as total_revenue
from segmented
group by segment
order by total_revenue desc;

select * from customer_segments_summary;