with
	RFM(user_id, r,f,m) as 
	# формируем таблицу пользователей с индексами
		(select user_id,
		CASE 
		    WHEN count(id_o) > 5 THEN '3'
		    WHEN count(id_o) > 2 THEN '2'
		    ELSE '1'
		    END AS f,
		CASE 
		    WHEN datediff('2017-12-31', max(o_date)) < 30 THEN '3'
		    WHEN datediff('2017-12-31', max(o_date)) < 60 THEN '2'
		    ELSE '1'
		    END AS r,
		CASE 
		    WHEN SUM(price) > 15000 THEN '3'
		    WHEN SUM(price) > 10000 THEN '2'
		    ELSE '1'
		    END AS m
		from orders group by user_id),
	assign_rfm(rfm, user_id) as
	# присваиваем пользователям сегмент RFM
		(select concat(r,f,m) as rfm, user_id from RFM),
	group_rfm(rfm, count_user, turnover) as
	# групперуем по рфм
		(select t.rfm, count(tt.user_id), sum(tt.price) from orders as tt left join assign_rfm as t on t.user_id = tt.user_id 
		group by t.rfm),
	group_cat(group_c, count_user, turnover) as	
	# vip, lost and regular
		(select
		CASE 
		    WHEN rfm = 333 THEN 'yip'
		    WHEN rfm = 233 THEN 'yip'
		    WHEN rfm = 111 THEN 'lost'
		    ELSE 'regular'
		    END AS group_c,
		    sum(count_user) as count_user,
		    sum(turnover) as turnover
		from group_rfm group by group_c),
	test(sours, count_u, sum_price) as
	# проверка
		(select 'original' as sours, count(user_id) as o_count_u, sum(price) as o_sum_price from orders 
		union all
		select 'function' as sours, sum(count_user) as o_count_u, sum(turnover) as o_sum_price from group_cat),
	count_group(group_c, c_user, c_turnover) as 
	# количество по группами
		(select group_c, sum(count_user), sum(turnover) from group_cat group by group_c
		union all
		select 'original' as group_c, count(user_id) as o_count_u, sum(price) as o_sum_price from orders),
	persent_group(group_c, per_user, per_turnover) as 
	# доли занимаемые группами
		(select group_c,
		sum(count_user) * 100 / (select  count(user_id) from orders),
		sum(turnover) * 100 / (select  sum(price) from orders)
		from group_cat group by group_c)
select * from persent_group;
