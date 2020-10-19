-- Скалярная функция PL/Python.
-- Возвращает минимальную сумму, которую придется потратить 
-- на жилье с учетом минимального количества ночей.
CREATE OR REPLACE FUNCTION get_minimal_spendings_py(minimum_nights INT, price DECIMAL)
RETURNS DECIMAL 
AS $$
    return minimum_nights * price
$$ LANGUAGE PLPYTHON3U;
SELECT price, minimum_nights, get_minimal_spendings_py(minimum_nights, price) FROM listings;

-- Пользовательская агрегатная функция PL/Python.
-- Возвращает среднюю сумму, которую придется потратить на основе всего жилья.
CREATE OR REPLACE FUNCTION get_avg_minimal_spendings_py()
RETURNS DECIMAL 
AS $$
    query = "select get_minimal_spendings_py(minimum_nights, price) from listings;"
    result = plpy.execute(query)
    qsum = 0
    qlen = len(result)
    for x in result:
        qsum += x["get_minimal_spendings_py"]
    return qsum / qlen
$$ LANGUAGE PLPYTHON3U;  
SELECT get_avg_minimal_spendings_py();

-- Определяемая пользователем табличная функция PL/Python.
-- Возвращает все жилье, принадлежащее hostname. 
CREATE OR REPLACE FUNCTION find_host_listings_py(hostname VARCHAR)
RETURNS TABLE (
    hostname VARCHAR,
    listing_id INT
) AS $$
    query = f"SELECT '{hostname}' hn, l.id lid FROM listings l WHERE l.host_name = '{hostname}';"
    result = plpy.execute(query)
    for x in result:
        yield(x["hn"], x["lid"])
$$ LANGUAGE PLPYTHON3U;
SELECT * FROM find_host_listings_py('David');

-- Хранимая процедура PL/Python.
-- Изменить цену типа жилья.
CREATE OR REPLACE PROCEDURE change_type_price_py(listtype VARCHAR, change DECIMAL)
AS $$
    plan = plpy.prepare(
        "UPDATE listings SET price = price + $1 WHERE room_type = $2;",
        ["INT", "VARCHAR"]
    )
    plpy.execute(plan, [change, listtype])
$$ LANGUAGE PLPYTHON3U;
CALL change_type_price_py('Private room', 20);

-- Триггер AFTER PL/Python.
-- Выводит предположение о расположении жилья в соседстве на основе его рейтинга.
CREATE OR REPLACE FUNCTION get_neighbourhood_mark_py()
RETURNS TRIGGER
AS $$
    if TD["new"]["rating"] < 7:
        plpy.notice(f"{TD['new']['neighbourhood']} likely will be placed at the bottom of bookings")
    else:
        plpy.notice(f"{TD['new']['neighbourhood']} likely will be placed at the top of bookings")
$$ LANGUAGE PLPYTHON3U;
CREATE TRIGGER neighbourhood_suggestion_py AFTER INSERT ON neighbourhoods
FOR ROW EXECUTE PROCEDURE get_neighbourhood_mark_py();
INSERT INTO neighbourhoods (neighbourhood, rating, chairman, chairman_phone)
VALUES ('Moscow', 10, 'Sergey', '(788) 856-4331');
DELETE FROM neighbourhoods WHERE chairman = 'Sergey';

-- Определяемый пользователем тип данных PL/Python.
CREATE TYPE name_price AS (
    name VARCHAR,
    price DECIMAL
);
CREATE OR REPLACE FUNCTION set_name_price_py(nm VARCHAR, pr DECIMAL)
RETURNS SETOF name_price
AS $$
    return ([nm, pr],)
$$ LANGUAGE PLPYTHON3U;
SELECT * FROM set_name_price_py('Book', 20);