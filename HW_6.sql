/* Создать структуру БД турфирмы (можно в экселе, как я показываю на занятиях).

Что должно содержаться: кто куда летит, когда, какая оплата, может лететь группа, 
могут быть пересадки на рейсах, какая страна или страны, какие города и отели, звездность отеля,
тип питания и комнат, данные о пассажирах, необходимость виз, ограничения, цель поездки,
 канал привлечения пользователя, бонусы и промокода и т.д.

Что получится - присылайте)*/

/*
 Модель данных для туристического агенства заключен в следующей схеме:
 Есть таблица пользователей которые заполнили анкету и в ней же указывается от куда(источник \ канал)
 пользователь пришел.
 Таблица туров - это таблица с сформироваными турами с указанием городов гостиниц стран и видом транспорта для донного тура
 также началом этого тура и окончанием т.е. справиочная информация по туру.
 Таблица sales - хранит в себе значения уже созданной продажи такие как пользователь тур количество купленных мест и дней в этом туре, выбор возможного 
 варианта прибытия в гостиницу.
 Таблицы город, страна, транспортный узел, и маршруты это справочники хранящие в себе данные о вариантах перемещения между городами, условиями
 въезда в страну уровнем сервиса и количеством мест в гостиницах
 в целом углубление справочников и ровно их нормализацию, БД можно продолжить но зависеть это должно от необходимой скорости работы(как самой базы так и написания скриптов к ней)
 с другой стороны это обудет отвечать за увеличение размера базы данных.
 Стоимость поездки в целом оценивается схематически по количеству мест в гостиниче * количество дней (стоимость в таблице гостиниц(весьма схематично т.к. необходим доп правочник 
 по номерам и их ценам)) и стоимости места + прямой и обратный трансфер из точки а в току б по таблице трансфер так же умноженному на количество мест указываемых в таблице sales.
 
 
*/


drop table if exists tur;
create table tur 
(
  id_tur SERIAL PRIMARY key COMMENT 'идентификатр тура',
  name varchar(255) COMMENT 'название тура',
  start_tour DATETIME COMMENT 'Начало турестического сезона по данному туру',
  end_torur DATETIME COMMENT 'Окончание езона по данному туру',
  country_host int unsigned COMMENT 'страна отбытия',
  town_host int unsigned COMMENT 'город отбытя',
  country_departure int unsigned COMMENT 'страна прибытия',
  town_departure int unsigned COMMENT ' город прибытия ',
  type_transport int unsigned COMMENT 'тип транспорта',
);


drop table if exists users;
create table users 
(
	id_user SERIAL PRIMARY KEY,
	surname varchar(255) COMMENT 'фамилия', 
	name varchar(255) COMMENT 'имя',
	patronymic varchar(255) COMMENT 'отчество',
	date_birth DATETIME COMMENT 'день роджения',
	data_registration DATETIME COMMENT 'дата регистрации на сайте',
	cookies varchar(255) COMMENT 'Название канала от куда пользователь'
	
);


drop table if exists hotel;
create table hotel
(
	id_hotel SERIAL PRIMARY key,
	name_hotel varchar(255) COMMENT 'название гостиницы',
	siti int COMMENT 'город местоположения',
	sters int COMMENT 'уровень сервиса и услуг',
	number_rooms int COMMENT 'количество номеров'
	price int COMMENT 'стоимость номера в сутки',

);


drop table if exists tansport_node;
create table transport_node
(
	id_tansport_node SERIAL PRIMARY key,
	id_siti int COMMENT 'номер города', 
    node ENUM( 'port','airport','railway_station','bus_station') COMMENT 'тип транспортного узла',
    addres varchar(255) COMMENT 'адрес транспортного узла'
);


drop table if exists site;
create table site 
(
	id_site SERIAL  primary key,
	id_countru int COMMENT 'код страны',
	name_site varchar(255) COMMENT 'название города'
);


drop table if exists country;
create table country 
(
	id_country SERIAL  primary key,
	name_country varchar(255) COMMENT 'название страны', 
	visa varchar(255) COMMENT 'условия прибытия',
	stert_season DATETIME COMMENT 'Начало туристического сезона',
	finich_season DATETIME COMMENT 'окончание туристического сезона'
);


drop table if exists sales;
create table sales 
(
	id_sales SERIAL PRIMARY KEY,
	id_tur int COMMENT ' код тура',
	id_user int COMMENT 'код пользователя',
	number_seats int COMMENT 'количество человек',
	id_promo int COMMENT ' код промокода',
	start_tour DATETIME COMMENT 'Начало поездки',
    end_torur DATETIME COMMENT 'Окончание поездки',
    id_hotel int COMMENT ' код отеля',
    id_tramsfer int COMMENT 'код маршрута',
    data_order DATETIME COMMENT 'дата покупки тура',
    key id_sales_id_tur(id_tur),
    key id_sales_id_user(id_user)
);

drop table if exists tramsfer;
create table tramsfer 
(
	id_tramsfer int COMMENT 'код маршрута',
	first_p int COMMENT 'код пункта а',
	second_p int COMMENT 'код пункта б',
	price int Coment 'стоимость маршрута'
);
