/*
 ДЗ делаем по бд orders
В качестве ДЗ сделаем карту поведения пользователей. 
Мы обсуждали, что всех пользователей можно разделить, к примеру, на New (совершили только 1 покупку), 
Regular (совершили 2 или более на сумму не более стольки-то), Vip (совершили дорогие покупки и достаточно часто), 
Lost (раньше покупали хотя бы раз и с даты последней покупки прошло больше 3 месяцев). 
Вся база должна войти в эти гурппы (т.е. каждый пользователь должен попадать только в одну из этих групп).

Задача:
1. Уточнить критерии групп New,Regular,Vip,Lost
2. По состоянию на 1.01.2017 понимаем, кто попадает в какую группу, подсчитываем кол-во пользователей в каждой.
3. По состоянию на 1.02.2017 понимаем, кто вышел из каждой из групп, а кто вошел.
4. Аналогично смотрим состояние на 1.03.2017, понимаем кто вышел из каждой из групп, а кто вошел.
5. В итоге делаем вывод, какая группа уменьшается, какая увеличивается и продумываем, в чем может быть причина.

Присылайте отчет в pdf
*/

/* формируем таблицу для внесения RFM и групп RFM */
drop table rfm;

create table rfm 
user_id int,
rfm varchar(5),
group_ varchar(10),
period int;

select count(user_id), period from rfm group by period;

update rfm set period = 201704 where period is null; /* вносим изменение периода в случае его отсутствия */

alter table RFM add period int(6) null; /* создаем поле период */

delete from RFM where period > 201703; /* удалить строки */

/* количество пользователей входящих в каждую группу */
select count(user_id), group_ from rfm 
where user_id in (select user_id from orders where date_format(o_date, '%Y%m') <=201704)
group by group_;

/* lost, regular, yip*/
/* написано верно и красиво 14 секунд выполнение */
/* дельта между 3 и 4 месяцами 2017 года */
with
	lost_701_regular_702 (user_id, napravlenie) as
		(select user_id, 'lost_703_regular_704' as napravlenie from rfm where group_ = 'regular' and period = 201704 and user_id in 
		(select user_id from rfm where group_ = 'lost' and period = 201703)),
	lost_701_yip_702 (user_id, napravlenie) as	
		(select user_id, 'lost_703_yip_704' as napravlenie from rfm where group_ = 'yip' and period = 201704 and user_id in 
		(select user_id from rfm where group_ = 'lost' and period = 201703)),
	regular_701_lost_702 (user_id, napravlenie) as	
		(select user_id, 'regular_703_lost_704' as napravlenie from rfm where group_ = 'lost' and period = 201704 and user_id in 
		(select user_id from rfm where group_ = 'regular' and period = 201703)),
	regular_701_yip_702 (user_id, napravlenie) as		
		(select user_id, 'regular_703_yip_704' as napravlenie from rfm where group_ = 'yip' and period = 201704 and user_id in 
		(select user_id from rfm where group_ = 'regular' and period = 201703)),
	yip_701_lost_702 (user_id, napravlenie) as	
		(select user_id, 'yip_703_lost_704' as napravlenie from rfm where group_ = 'lost' and period = 201704 and user_id in 
		(select user_id from rfm where group_ = 'yip' and period = 201703)),
	yip_701_regular_702 (user_id, napravlenie) as	
		(select user_id, 'yip_703_regular_704' as napravlenie from rfm where group_ = 'regular' and period = 201704 and user_id in 
		(select user_id from rfm where group_ = 'yip' and period = 201703)),
	dvij (user_id, napravlenie) as
		(select user_id, napravlenie from yip_701_regular_702 union
		select user_id, napravlenie from yip_701_lost_702 union
		select user_id, napravlenie from regular_701_lost_702 union
		select user_id, napravlenie from regular_701_yip_702 union
		select user_id, napravlenie from lost_701_yip_702 union
		select user_id, napravlenie from lost_701_regular_702)
select count(user_id), napravlenie from dvij group by napravlenie;

/* распределяем пользователей по группам RFM */
with
	rfm_ (user_id, r, f, m) as
(select user_id, 
		CASE 
		    WHEN count(id_o) > 5 THEN '3'
		    WHEN count(id_o) > 2 THEN '2'
		    ELSE '1'
		    END AS f,
		CASE 
		    WHEN datediff('2017-12-31', max(o_date)) < 30 THEN '3' /* при изменении предела меняем точку отчета */
		    WHEN datediff('2017-12-31', max(o_date)) < 60 THEN '2'
		    ELSE '1'
		    END AS r,
		CASE 
		    WHEN SUM(price) > 15000 THEN '3'
		    WHEN SUM(price) > 10000 THEN '2'
		    ELSE '1'
		    END AS m
		from orders where user_id not in (select user_id 
											from (select user_id, o_date from orders group by user_id having count(id_o) = 1) as t 
											where date_format(o_date, '%Y%m') <= '201612') /* убираем еденичные покупки до декабря 2016 */
					and id_o not in (select id_o 
											from (select id_o, o_date from orders) as t 
											where date_format(o_date, '%Y%m') >= '201712') /* отсекаем предел исследования */
	    group by user_id),
		rfm_v (user_id, rfm) as 
(select user_id, concat(r, f, m) as rfm from rfm_),		
	group_cat(user_id, rfm, group_) as	
	# vip, lost and regular
(select user_id, rfm,
		CASE 
		    WHEN rfm = 333 THEN 'yip'
		    WHEN rfm = 233 THEN 'yip'
		    WHEN rfm = 111 THEN 'lost'
		    ELSE 'regular'
		    END AS group_		
		from rfm_v)
select * from group_cat;

