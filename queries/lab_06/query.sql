-- Выполнить скалярный запрос.
-- Вывести средний рейтинг соседств.
SELECT AVG(rating) from neighbourhoods;

-- Выполнить запрос с несколькими соединениями (JOIN).
-- Вывести все сведения о жилье и соседствах.
SELECT * FROM listings l JOIN neighbourhoods n ON l.neighbourhood = n.neighbourhood;

-- Выполнить запрос с ОТВ(CTE) и оконными функциями.
-- Создать таблицу с лучшим жильем доступным бОльшую часть года.
WITH everyday_best_listings (name, neighbourhood, rating, availability_365) AS (
    SELECT name, listings.neighbourhood, rating, availability_365 FROM listings JOIN neighbourhoods
    ON listings.neighbourhood = neighbourhoods.neighbourhood 
    WHERE rating > 7 AND availability_365 > 183
)
SELECT * FROM everyday_best_listings;
SELECT DISTINCT name, room_type, AVG(price) OVER(PARTITION BY room_type) AS avg_price FROM listings;

-- Выполнить запрос к метаданным.
-- Вывести id и лимит подключений к текущей базе данных.
SELECT pg.oid, pg.datconnlimit FROM pg_database pg WHERE pg.datname = 'dbcourse';

-- Вызвать скалярную функцию (написанную в третьей лабораторной работе).
SELECT price, minimum_nights, get_minimal_spendings(minimum_nights, price) FROM listings;

-- Вызвать многооператорную или табличную функцию (написанную в третьей лабораторной работе).
SELECT * FROM find_host_listings('David');

-- Вызвать хранимую процедуру (написанную в третьей лабораторной работе).
CALL change_type_price('Private room', 20);

-- Вызвать системную функцию или процедуру.
-- Вывести имя текущей базы данных.
SELECT * FROM current_database();

-- Создать таблицу в базе данных, соответствующую тематике БД.
-- Создать таблицу доступного в данном жилье транспорта.
CREATE TABLE available_transport (
    id SERIAL PRIMARY KEY,
    listing_id INT NOT NULL,
    name VARCHAR NOT NULL,
    price DECIMAL(6,2) CHECK (price >= 0),
    FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE
);

-- Выполнить вставку данных в созданную таблицу с использованием инструкции INSERT или COPY.
-- Вставить транспорт в таблицу.
INSERT INTO available_transport (listing_id, name, price)
VALUES (3209, 'Motorcycle', 30);