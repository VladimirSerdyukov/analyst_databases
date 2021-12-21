/* Создать структуру БД турфирмы (можно в экселе, как я показываю на занятиях).

Что должно содержаться: кто куда летит, когда, какая оплата, может лететь группа, 
могут быть пересадки на рейсах, какая страна или страны, какие города и отели, звездность отеля,
тип питания и комнат, данные о пассажирах, необходимость виз, ограничения, цель поездки,
 канал привлечения пользователя, бонусы и промокода и т.д.

Что получится - присылайте)*/


drop table if exists tur;
create table tur 
(
  id_tur SERIAL PRIMARY KEY,
  name varchar(255),
  start_tour DATETIME COMMENT 'Начало турестического сезона по данному туру',
  end_torur DATETIME COMMENT 'Окончание езона по данному туру',
  country_host int UNSIGNED,
  town_host int UNSIGNED,
  country_departure int UNSIGNED,
  town_departure int UNSIGNED,
  type_transport int UNSIGNED,

  KEY index_of_user_id(user_id),
  KEY index_of_product_id(product_id)
);


drop table if exists users;
create table users 
(
	id_user SERIAL PRIMARY KEY,
	surname varchar(255),
	name varchar(255),
	patronymic varchar(255),
	date_birth DATETIME,
	data_registration DATETIME,
	cookies varchar(255)COMMENT 'Название канала от куда пользователь'
	
);


drop table if exists sales;
create table sales 
(
	id_sales SERIAL PRIMARY KEY,
	id_tur int,
	id_user int,
	number_seats int,
	id_promo int,
	start_tour DATETIME COMMENT 'Начало поездки',
    end_torur DATETIME COMMENT 'Окончание поездки',
    id_hotel int,
    id_tramsfer int	
);
