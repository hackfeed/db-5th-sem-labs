-- Инструкция SELECT, использующая предикат сравнения.
-- Вывести жилье, у которого больше 100 отзывов.
SELECT name, number_of_reviews FROM listings WHERE number_of_reviews > 100;
-- Инструкция SELECT, использующая предикат BETWEEN.
-- Вывести соседства, рейтинг которых в диапазоне от 7 до 9.
SELECT neighbourhood, rating FROM neighbourhoods WHERE rating BETWEEN 7 AND 9;
-- Инструкция SELECT, использующая предикат LIKE.
-- Вывести жилье, имя владельца которого начинается на 'Mar'.
SELECT name, host_name FROM listings WHERE host_name LIKE 'Mar%';
-- Инструкция SELECT, использующая предикат IN с вложенным подзапросом.
-- Вывести жилье, находящееся в соседствах с рейтингом больше 7.
SELECT name, neighbourhood FROM listings WHERE neighbourhood IN
(SELECT neighbourhood FROM neighbourhoods WHERE rating > 7);
-- Инструкция SELECT, использующая предикат EXISTS с вложенным подзапросом.
-- Вывести жилье, отзывы о котором оставляла Natalie.
SELECT id, name FROM listings WHERE EXISTS 
(SELECT listing_id FROM reviews WHERE reviewer_name = 'Natalie');
-- Инструкция SELECT, использующая предикат сравнения с квантором.
-- Вывести жилье типа 'Private room', в котором минимум ночей больше чем в любом жилье типа 
-- 'Entire home/apt'.
SELECT name, minimum_nights FROM listings WHERE room_type = 'Private room' AND minimum_nights >
ALL(SELECT minimum_nights FROM listings WHERE room_type = 'Entire home/apt');
-- Инструкция SELECT, использующая агрегатные функции в выражениях столбцов.
-- Вывести среднее значение минимального числа ночей в соседстве 'Centrum-West'.
SELECT AVG(minimum_nights) AS avg_minimum_nights FROM listings WHERE neighbourhood = 'Centrum-West';
-- Инструкция SELECT, использующая скалярные подзапросы в выражениях столбцов.
-- Вывести жилье со средним рейтингом соседства, цена жилья меньше 300.
SELECT name, neighbourhood, (SELECT AVG(rating) from neighbourhoods) as avg_neighbourhood_rating, price 
FROM listings WHERE price < 300;
-- Инструкция SELECT, использующая простое выражение CASE.
-- Вывести id жилья и дату из календаря. В случае, если цена NULL, заменить её на 'Ask the manager'.
SELECT listing_id, date,
CASE
WHEN price IS NULL THEN 'Ask the manager'
ELSE CAST (price AS VARCHAR)
END price
FROM calendar;
-- Инструкция SELECT, использующая поисковое выражение CASE.
-- Вывести жилье и оценку стоимости
SELECT name, room_type, price
CASE
WHEN price < 100 THEN 'Cheap'
WHEN price < 200 THEN 'Fair'
WHEN price < 300 THEN 'Expensive'
ELSE 'Very expensive'
END price_mark
FROM listings;
-- Создание новой временной локальной таблицы из результирующего набора данных инструкции SELECT.
-- Создание временной локальной таблицы с соседствами, рейтинг которых больше 7.
CREATE TEMP TABLE best_neighbourhoods AS
SELECT neighbourhood, rating, chairman, chairman_phone FROM neighbourhoods WHERE rating > 7;
-- Инструкция SELECT, использующая вложенные коррелированные подзапросы 
-- в качестве производных таблиц в предложении FROM.
-- Вывести жилье, владельцем которого является председатель соседства.
SELECT name, lsts.neighbourhood, rating, chairman, host_name FROM listings lsts JOIN LATERAL 
(SELECT neighbourhood, rating, chairman FROM neighbourhoods WHERE lsts.host_name = chairman) 
AS rating_chairman ON lsts.neighbourhood = rating_chairman.neighbourhood;
-- Инструкция SELECT, использующая вложенные подзапросы с уровнем вложенности 3.
-- Мне очень сложно было придумать запрос с вложенностью 3 поэтому я сам не до конца понимаю что 
-- здесь выводится.
SELECT DISTINCT listing_id FROM calendar WHERE date IN (
    SELECT date FROM reviews WHERE reviewer_name IN (
        SELECT host_name FROM listings WHERE neighbourhood IN (
            SELECT neighbourhood FROM neighbourhoods WHERE rating < 8
        )
    )
);
-- Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY, но без предложения HAVING.
-- Вывести жилье по соседствам с общим количеством вариантов и средней ценой.
SELECT neighbourhood, COUNT(name) AS qty_listings, AVG(price) AS avg_price FROM listings GROUP BY neighbourhood; 
-- Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY и предложения HAVING.
-- Вывести жилье по соседствам с общим количеством вариантов и средней ценой и количеством вариантов > 1000.
SELECT neighbourhood, COUNT(name) AS qty_listings, AVG(price) AS avg_price FROM listings GROUP BY neighbourhood
HAVING COUNT(name) > 1000;
-- Однострочная инструкция INSERT, выполняющая вставку в таблицу одной строки значений.
-- Добавление нового соседства.
INSERT INTO neighbourhoods (neighbourhood, rating, chairman, chairman_phone)
VALUES ('Moscow', 10, 'Sergey', '(788) 856-4331');
-- Многострочная инструкция INSERT, выполняющая вставку в таблицу результирующего набора данных вложенного подзапроса.
-- Добавление нового соседства но с селектом.
INSERT INTO neighbourhoods (neighbourhood, rating, chairman, chairman_phone)
SELECT 'Tambov', rating-3, 'Oleg', chairman_phone FROM neighbourhoods 
WHERE chairman = 'Sergey' AND neighbourhood = 'Moscow'; 
-- Простая инструкция UPDATE.
-- Обновление председателя соседства.
UPDATE neighbourhoods SET chairman = 'Lyosha' WHERE neighbourhood = 'Tambov';
-- Инструкция UPDATE со скалярным подзапросом в предложении SET.
-- Обновление рейтинга соседства.
UPDATE neighbourhoods SET rating = (SELECT AVG(rating) FROM neighbourhoods) 
WHERE chairman = 'Lyosha';
-- Простая инструкция DELETE.
-- Удаляем Лешу, надоел он мне.
DELETE FROM neighbourhoods WHERE chairman = 'Lyosha';
-- Инструкция DELETE с вложенным коррелированным подзапросом в предложении WHERE.
-- Меня тоже удалим, но по-хитрому.
DELETE FROM neighbourhoods WHERE rating IN 
(SELECT MAX(rating) FROM neighbourhoods WHERE chairman LIKE 'Ser%');
-- Инструкция SELECT, использующая простое обобщенное табличное выражение.
-- Создать таблицу с лучшим жильем доступным бОльшую часть года.
WITH everyday_best_listings (name, neighbourhood, rating, availability_365) AS (
    SELECT name, listings.neighbourhood, rating, availability_365 FROM listings JOIN neighbourhoods
    ON listings.neighbourhood = neighbourhoods.neighbourhood 
    WHERE rating > 7 AND availability_365 > 183
)
SELECT * FROM everyday_best_listings;
-- Инструкция SELECT, использующая рекурсивное обобщенное табличное выражение.
-- Вывести сумму жилья типа 'Entire home/apt'.
WITH RECURSIVE room_type_price (room_type, price) AS (
    SELECT room_type, price FROM listings
    WHERE room_type = 'Entire home/apt'
    UNION ALL
    SELECT rtp.room_type, rtp.price FROM room_type_price rtp
    WHERE room_type = rtp.room_type 
)
SELECT SUM(price) FROM room_type_price;
-- Оконные функции. Использование конструкций MIN/MAX/AVG OVER().
-- Выисляет среднюю цену типа жилья.
SELECT DISTINCT name, room_type, AVG(price) OVER(PARTITION BY room_type) AS avg_price FROM listings;
-- Оконные фнкции для устранения дублей.
-- Ну это прям минус мозг, я спать.
CREATE TABLE test (
    name VARCHAR NOT NULL,
    surname VARCHAR NOT NULL
);
INSERT INTO test (name, surname) VALUES ('Sergey', 'Kononenko'), ('Sergey', 'Kononenko');
WITH test_deleted AS
(DELETE FROM test RETURNING *),
test_inserted AS
(SELECT name, surname, ROW_NUMBER() OVER(PARTITION BY name, surname ORDER BY name, surname) rownum FROM test_deleted)
INSERT INTO test SELECT name, surname FROM test_inserted WHERE rownum = 1;
DROP TABLE TEST;