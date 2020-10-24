-- Скалярная функция.
-- Возвращает минимальную сумму, которую придется потратить 
-- на жилье с учетом минимального количества ночей.
CREATE OR REPLACE FUNCTION get_minimal_spendings(minimum_nights INT, price DECIMAL)
RETURNS DECIMAL AS $$
BEGIN
    RETURN minimum_nights * price;
END;
$$ LANGUAGE PLPGSQL;
SELECT price, minimum_nights, get_minimal_spendings(minimum_nights, price) FROM listings;

-- Подставляемая табличная функция.
-- Возвращает таблицу вида (имя, цена, соседство, рейтинг) 
-- с ценой меньше указанной и указанным соседством.
CREATE TABLE typedtbl (
    name VARCHAR,
    price DECIMAL(6,2),
    neighbourhood VARCHAR,
    rating DECIMAL(4,2)
);
CREATE OR REPLACE FUNCTION get_listings_in_neighbourhood_above_price(_tbl_type ANYELEMENT, defined_price DECIMAL, defined_neighbourhood VARCHAR)
RETURNS SETOF ANYELEMENT
AS $$
BEGIN
    RETURN QUERY
    EXECUTE
    'SELECT l.name, l.price, l.neighbourhood, n.rating FROM listings l JOIN neighbourhoods n 
    ON l.neighbourhood = n.neighbourhood 
    WHERE l.price < $1 AND l.neighbourhood = $2'
    USING defined_price, defined_neighbourhood;
END;
$$ LANGUAGE PLPGSQL;  
SELECT * FROM get_listings_in_neighbourhood_above_price(NULL::typedtbl, 300, 'Bijlmer-Oost');

-- Многооператорная табличная функция.
-- Возвращает все жилье, принадлежащее hostname. 
CREATE OR REPLACE FUNCTION find_host_listings(hostnm VARCHAR)
RETURNS TABLE (
    hostname VARCHAR,
    listing_id INT,
    min_money DECIMAL
) AS $$
BEGIN
    CREATE TEMP TABLE tbl (
        hostname VARCHAR,
        listing_id INT,
        min_money DECIMAL
    );
    INSERT INTO tbl (hostname, listing_id, min_money)
    SELECT hostnm, l.id, l.minimum_nights * l.price FROM listings l WHERE l.host_name = hostnm;
    RETURN QUERY
    SELECT * FROM tbl;
END;
$$ LANGUAGE PLPGSQL;
SELECT * FROM find_host_listings('David');

-- Рекурсивная функция.
-- Можно ли дойти от соседства А до соседства Б не более чем за N шагов.
CREATE OR REPLACE FUNCTION get_neighbourhoods_hops(from_neighbourhood VARCHAR, to_neighbourhood VARCHAR, hops INT)
RETURNS TABLE (
    id INT,
    neighbourhood VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    WITH RECURSIVE all_neighbours (id, neighbourhood) AS (
        SELECT n.id, n.neighbourhood, 0 AS level FROM neighbourhoods n
        WHERE n.neighbourhood = from_neighbourhood
        UNION ALL
        SELECT nbh.id, nbh.neighbourhood, level + 1 FROM neighbourhoods nbh
        JOIN all_neighbours an ON nbh.id = an.id + 1 AND level < hops
    )
    SELECT an.id, an.neighbourhood FROM all_neighbours an WHERE an.neighbourhood = to_neighbourhood;
END;
$$ LANGUAGE PLPGSQL;  
SELECT * FROM get_neighbourhoods_hops('Centrum-Oost', 'De Aker - Nieuw Sloten', 5);

-- Хранимая процедура с параметрами.
-- Изменить цену типа жилья.
CREATE OR REPLACE PROCEDURE change_type_price(listtype VARCHAR, change DECIMAL)
AS $$
BEGIN
    UPDATE listings
    SET price = price + change
    WHERE room_type = listtype;
    COMMIT;
END;
$$ LANGUAGE PLPGSQL;
CALL change_type_price('Private room', 20);

-- Рекурсивная хранимая процедура.
-- Показывает, в каком районе в данный момент вы находитесь и
-- совершает путешествие до начального района города.
CREATE OR REPLACE PROCEDURE find_hops_to_start(from_neighbourhood VARCHAR)
AS $$
DECLARE
    curid INT;
    curnbh VARCHAR;
BEGIN
    SELECT n.id FROM neighbourhoods n WHERE n.neighbourhood = from_neighbourhood 
    INTO curid;
    IF curid = 1 THEN
        RAISE NOTICE 'You are at the start of the city!';
    ELSE
        SELECT n.neighbourhood FROM neighbourhoods n WHERE n.id = curid - 1
        INTO curnbh;
        RAISE NOTICE 'You are now at %s. Keep going!', curnbh;
        CALL find_hops_to_start(curnbh);
    END IF;
END;
$$ LANGUAGE PLPGSQL;
CALL find_hops_to_start('De Aker - Nieuw Sloten');

-- Хранимая процедура с курсором.
-- Выводит все жилье заданного типа с ценой меньше заданной.
CREATE OR REPLACE PROCEDURE fetch_listings_by_type(listtype VARCHAR, listprice DECIMAL)
AS $$
DECLARE 
    reclist RECORD;
    listcur CURSOR FOR
        SELECT * FROM listings l 
        WHERE l.room_type = listtype AND l.price < listprice AND l.name IS NOT NULL;
BEGIN
    OPEN listcur;
    LOOP
        FETCH listcur INTO reclist;
        RAISE NOTICE '% is % and only for %!', reclist.name, listtype, reclist.price;
        EXIT WHEN NOT FOUND;
    END LOOP;
    CLOSE listcur;
END;
$$ LANGUAGE PLPGSQL;
CALL fetch_listings_by_type('Private room', 300);

-- Хранимая процедура доступа к метаданным.
-- Выводит имя, ID и максимальное число параллельных соединений
-- по имени БД.
CREATE OR REPLACE PROCEDURE get_db_metadata(dbname VARCHAR)
AS $$
DECLARE
    dbid INT;
    dbconnlimit INT;
BEGIN
    SELECT pg.oid, pg.datconnlimit FROM pg_database pg WHERE pg.datname = dbname
    INTO dbid, dbconnlimit;
    RAISE NOTICE 'DB: %, ID: %, CONNECTION LIMIT: %', dbname, dbid, dbconnlimit;
END;
$$ LANGUAGE PLPGSQL;
CALL get_db_metadata('dbcourse');

-- Триггер AFTER.
-- Выводит предположение о расположении жилья в соседстве на основе его рейтинга.
CREATE OR REPLACE FUNCTION get_neighbourhood_mark()
RETURNS TRIGGER
AS $$
BEGIN
    IF NEW.rating < 7 THEN
        RAISE NOTICE '% likely will be placed at the bottom of bookings', NEW.neighbourhood;
    ELSE
        RAISE NOTICE '% likely will be placed at the top of bookings', NEW.neighbourhood;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;
CREATE TRIGGER neighbourhood_suggestion AFTER INSERT ON neighbourhoods
FOR ROW EXECUTE PROCEDURE get_neighbourhood_mark();
INSERT INTO neighbourhoods (neighbourhood, rating, chairman, chairman_phone)
VALUES ('Moscow', 10, 'Sergey', '(788) 856-4331');
DELETE FROM neighbourhoods WHERE chairman = 'Sergey';

-- Триггер INSTEAD OF.
-- Добавляет жилье в базу, если владелец на момент добавления имеет менее 10 активных
-- лотов жилья в букинге.
CREATE OR REPLACE FUNCTION insert_listing()
RETURNS TRIGGER
AS $$
DECLARE
    listingscnt INT;
    hostname VARCHAR;
BEGIN
    SELECT l.host_name, COUNT(*) FROM listings l
    WHERE l.host_id = NEW.host_id
    GROUP BY l.host_name
    INTO hostname, listingscnt;
    IF listingscnt >= 10 THEN
        RAISE EXCEPTION '% already have more than 10 listings on booking. Aborting.', hostname;
        RETURN NULL;
    ELSE
        RAISE NOTICE '% listings left for %', 9 - listingscnt, hostname;
        INSERT INTO listings (
            id,
            name,
            host_id,
            host_name,
            neighbourhood,
            latitude,
            longitude,
            room_type,
            price,
            minimum_nights,
            number_of_reviews,
            last_review,
            reviews_per_month,
            calculated_host_listings_count,
            availability_365
        )
        VALUES (
            NEW.id,
            NEW.name,
            NEW.host_id,
            NEW.host_name,
            NEW.neighbourhood,
            NEW.latitude,
            NEW.longitude,
            NEW.room_type,
            NEW.price,
            NEW.minimum_nights,
            NEW.number_of_reviews,
            NEW.last_review,
            NEW.reviews_per_month,
            NEW.calculated_host_listings_count,
            NEW.availability_365
        );
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE PLPGSQL;
CREATE VIEW listingsview AS
SELECT * FROM listings LIMIT 10;
CREATE TRIGGER listing_insertion INSTEAD OF INSERT ON listingsview
FOR EACH ROW EXECUTE PROCEDURE insert_listing();
INSERT INTO listingsview (
    id,
    name,
    host_id,
    host_name,
    neighbourhood,
    latitude,
    longitude,
    room_type,
    price,
    minimum_nights,
    number_of_reviews,
    last_review,
    reviews_per_month,
    calculated_host_listings_count,
    availability_365
)
VALUES (
    3210,
    'Quiet apt near center, great view',
    3806,
    'Maartje',
    'Westerpark',
    52.39022505041120,
    4.87392409474286,
    'Entire home/apt',
    160.00,
    4,
    42,
    '2018-08-29',
    1.03,
    1,
    47
);
DELETE FROM listings WHERE id = 3210;

-- Защита.
-- Написать триггер, который будет в новую таблицу добавлять информацию о том, сколько
-- записей было вставлено и в какую таблицу они были вставлены.
CREATE OR REPLACE FUNCTION add_insert_metadata()
RETURNS TRIGGER
AS $$
DECLARE
    cntbefore INT;
    cntafter INT;
BEGIN
    SELECT COALESCE(SUM(inserted),0) FROM metatable WHERE tablename = 'neighbourhoods' INTO cntbefore;
    SELECT COALESCE(COUNT(*), 0) FROM neighbourhoods INTO cntafter;
    INSERT INTO metatable (
        tablename,
        inserted
    )
    VALUES (
        'neighbourhoods',
        cntafter - cntbefore
    );
    DELETE FROM metatable WHERE inserted = 0;
    RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;
CREATE TABLE metatable (
    tablename VARCHAR,
    inserted INT
);
CREATE TRIGGER neighbourhood_insertion AFTER INSERT ON neighbourhoods
FOR EACH ROW EXECUTE PROCEDURE add_insert_metadata();
INSERT INTO neighbourhoods (
    neighbourhood,
    rating,
    chairman,
    chairman_phone
)
VALUES (
    'Super flexxxччччвфывфыв',
    10,
    'Sergey',
    '(788) 856-4331'
);
DELETE FROM neighbourhoods WHERE chairman = 'Sergey';
DELETE FROM metatable WHERE tablename = 'neighbourhoods';
