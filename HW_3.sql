/*
ДЗ
В качестве ДЗ делам прогноз ТО на 05.2017. В качестве метода прогноза - считаем сколько денег тратят группы клиентов в день:
1. Группа часто покупающих (3 и более покупок) и которые последний раз покупали не так давно.
 Считаем сколько денег оформленного заказа приходится на 1 день. Умножаем на 30.
2. Группа часто покупающих, но которые не покупали уже значительное время.
 Так же можем сделать вывод, из такой группы за след месяц сколько купят и на какую сумму. (постараться продумать логику)
3. Отдельно разобрать пользователей с 1 и 2 покупками за все время, прогнозируем их.
4. В итоге у вас будет прогноз ТО и вы сможете его сравнить с фактом и оценить грубо разлет по данным.
Как источник данных используем данные по продажам за 2 года.
*/
/* при всей грозности запроса выполняется у меня за 1 минуту */
 with u_3_order(user_id) as 
	 #  пользователи совершившие 4 и более покупок за весь период до 2017.05.01
	 (select user_id from orders where date_format(o_date, '%y%m') < '1705' group by user_id having count(id_o) >= 4),
	 in_1704_a(status, user_id, sum_p, count_o) as
	 # пользовтель из активных с суммой покупок в 3-м месяце
	 (select 'vip', user_id, sum(price), count(id_o) from orders
	 	where user_id in (select * from u_3_order) and date_format(o_date, '%y%m') = '1704' 
	 		group by user_id),
	 in_1703_a(status,  user_id, sum_p, count_o) as
	 #  пользовтель из активных с суммой покупок в 4-м месяце
	 (select 'vip', user_id, sum(price), count(id_o) from orders
	 	where user_id in (select * from u_3_order) and date_format(o_date, '%y%m') = '1703' 
	 		group by user_id),
	 u_2_order(user_id) as 
	 #  пользователи совершившие 2 и более покупок за весь период до 2017.05.01
	 (select user_id from orders where date_format(o_date, '%y%m') < '1705' group by user_id having count(id_o) >= 2 and count(id_o) < 4),
	 in_1704_avg(status, user_id, sum_p, count_o) as
	 # пользовтель из средних с суммой покупок в 3-м месяце
	 (select 'avg', user_id, sum(price), count(id_o) from orders
	 	where user_id in (select * from u_2_order) and date_format(o_date, '%y%m') = '1704' 
	 		group by user_id),
	 in_1703_avg(status, user_id, sum_p, count_o) as
	 #  пользовтель из средних с суммой покупок в 4-м месяце
	 (select 'avg', user_id, sum(price), count(id_o) from orders
	 	where user_id in (select * from u_2_order) and date_format(o_date, '%y%m') = '1703' 
	 		group by user_id),
	 u_new_order_1(user_id) as 
	 # новые пользователи в период от 2017.03.01 до 2017.04.01
	 (select user_id from orders where date_format(o_date, '%y%m') < '1702' group by user_id having count(id_o) = 1 ),
	 u_new_order_2(user_id) as 
	 # новые пользователи в период от 2017.04.01 до 2017.05.01
	 (select user_id from orders where date_format(o_date, '%y%m') < '1703' group by user_id having count(id_o) = 1),
	 in_1703_new(status, user_id, sum_p, count_o) as
	 # новички с суммой покупок в 3-м месяце
	 (select 'new',  user_id, sum(price), count(id_o) from orders
	 	where user_id not in (select * from u_new_order_1)and
	 	user_id not in (select * from u_3_order) and
	 	user_id not in (select * from u_2_order) and date_format(o_date, '%y%m') = '1703' 
	 		group by user_id),
	 in_1704_new(status, user_id, sum_p, count_o) as
	 #  новички с суммой покупок в 4-м месяце
	 (select 'new', user_id, sum(price), count(id_o) from orders
	 	where user_id not in (select * from u_new_order_2) and
	 	user_id not in (select * from u_3_order) and
	 	user_id not in (select * from u_2_order) and date_format(o_date, '%y%m') = '1704' 
	 		group by user_id),
	 new_user(grup, month03, month04) as 
	 # групперовка новых пользователей
	 (select status, sum(sum_p), (select sum(sum_p) from in_1704_new) from in_1703_new),
	 avg_user(grup, month03, month04) as 
	 # групперовка avg пользователей
	 (select status, sum(sum_p), (select sum(sum_p) from in_1704_avg) from in_1703_avg),
	 vip_user(grup, month03, month04) as 
	 # групперовка vip пользователей
	 (select status, sum(sum_p), (select sum(sum_p) from in_1704_a) from in_1703_a)
	 # коэффицент взят из разности сезонных коэффицентов за 2016 год из дз_1 
select null, sum(month03), sum(month04), sum(predskaz) from (
select grup, month03, month04, month03*0.044431+month03 as predskaz from new_user union all 
select grup, month03, month04, month03*0.044431+month03 as predskaz from avg_user union all 
select grup, month03, month04, month03*0.044431+month03 as predskaz from vip_user) as d;
/* прогноз получается 224 332 611 */

/*  фактический оборот  217 075 552*/
select sum(price) from orders where date_format(o_date, '%y%m') = '1705';
