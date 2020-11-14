-- Из таблиц базы данных, созданной в первой лабораторной работе, извлечь данные в JSON.
\t
\a
\o /dbdata/listings.json
SELECT ROW_TO_JSON(r) FROM listings r;
\t
\a
\o /dbdata/neighbourhoods.json
SELECT ROW_TO_JSON(r) FROM neighbourhoods r;
\t
\a
\o /dbdata/reviews.json
SELECT ROW_TO_JSON(r) FROM reviews r;
\t
\a
\o /dbdata/calendar.json
SELECT ROW_TO_JSON(r) FROM calendar r;

-- Выполнить загрузку и сохранение XML или JSON файла в таблицу.
-- Созданная таблица после всех манипуляций должна соответствовать таблице
-- базы данных, созданной в первой лабораторной работе.
CREATE TABLE neighbourhoods_from_json (
    neighbourhood VARCHAR PRIMARY KEY,
    rating DECIMAL(4,2) NOT NULL,
    chairman VARCHAR NOT NULL,
    chairman_phone VARCHAR(15) NOT NULL
);
CREATE TABLE temp (
    data jsonb
);
COPY temp (data) FROM '/dbdata/neighbourhoods.json';
INSERT INTO neighbourhoods_from_json (neighbourhood, rating, chairman, chairman_phone)
SELECT data->>'neighbourhood', (data->>'rating')::DECIMAL, data->>'chairman', data->>'chairman_phone' FROM temp;

-- Создать таблицу, в которой будет атрибут(-ы) с типом XML или JSON, или
-- добавить атрибут с типом XML или JSON к уже существующей таблице.
-- Заполнить атрибут правдоподобными данными с помощью команд INSERT
-- или UPDATE.
CREATE TABLE context (
    data jsonb
);
INSERT INTO context (data) VALUES 
('{"name": "Sergey", "age": 20, "education": {"university": "BMSTU", "graduation_year": 2022}}'), 
('{"name": "Alexey", "age": 20, "education": {"university": "BMSTU", "graduation_year": 2022}}');

-- Извлечь JSON фрагмент из JSON документа.
SELECT data->'education' education FROM context;

-- Извлечь значения конкретных узлов или атрибутов JSON документа.
SELECT data->'education'->'university' university FROM context;

-- Выполнить проверку существования узла или атрибута.
CREATE FUNCTION if_key_exists(json_to_check jsonb, key text)
RETURNS BOOLEAN 
AS $$
BEGIN
    RETURN (json_to_check->key) IS NOT NULL;
END;
$$ LANGUAGE PLPGSQL;
SELECT if_key_exists('{"name": "Sergey", "age": 20}', 'education');
SELECT if_key_exists('{"name": "Sergey", "age": 20}', 'name');

-- Изменить JSON документ.
UPDATE context SET data = data || '{"age": 21}'::jsonb WHERE (data->'age')::INT = 20;

-- Разделить JSON документ на несколько строк по узлам.
SELECT * FROM jsonb_array_elements('[
    {"name": "Sergey", "age": 20, "education": {"university": "BMSTU", "graduation_year": 2022}},
    {"name": "Alexey", "age": 20, "education": {"university": "BMSTU", "graduation_year": 2022}}
]');