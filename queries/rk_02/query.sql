-- Вариант 2
-- РК2 Кононенко ИУ7-53Б
-- gavrilovajm@bmstu.ru 

-- 1
DROP DATABASE IF EXISTS rk2;
CREATE DATABASE rk2;
\c rk2;

CREATE TABLE executors (
    id SERIAL PRIMARY KEY,
    fio VARCHAR NOT NULL,
    birth_year INT NOT NULL,
    experience VARCHAR NOT NULL,
    phone VARCHAR NOT NULL
);

CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    fio VARCHAR NOT NULL,
    birth_year INT NOT NULL,
    experience VARCHAR NOT NULL,
    phone VARCHAR NOT NULL
);

CREATE TABLE activities (
    id SERIAL PRIMARY KEY,
    activity_name VARCHAR NOT NULL,
    labor VARCHAR NOT NULL,
    equipment VARCHAR NOT NULL
);

CREATE TABLE executors_customers (
    executor_id INT,
    customer_id INT,
    FOREIGN KEY (executor_id) REFERENCES executors(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
);

CREATE TABLE executors_activities (
    executor_id INT,
    activity_id INT,
    FOREIGN KEY (executor_id) REFERENCES executors(id) ON DELETE CASCADE,
    FOREIGN KEY (activity_id) REFERENCES activities(id) ON DELETE CASCADE
);

CREATE TABLE customers_activities (
    customer_id INT,
    activity_id INT,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    FOREIGN KEY (activity_id) REFERENCES activities(id) ON DELETE CASCADE
);

INSERT INTO executors (fio, birth_year, experience, phone) VALUES
('Sergey', 2000, 'Good', '+7-907-555-6505'),
('Pasha', 2000, 'Aweesome', '+7-909-555-3636'),
('Lyosha', 2000, 'Super', '+7-902-555-1483'),
('Dima', 2000, 'Poor', '+7-909-555-8364'),
('Artem', 2000, 'Awful', '+7-925-553-0044'),
('Igor', 2000, 'Cool', '+7-951-555-3321'),
('Maxim', 2000, 'Flex', '+7-951-555-8033'),
('Sasha', 2000, 'Cool', '+7-908-555-0847'),
('Ed', 2000, 'Ok', '+7-952-555-7675'),
('John', 2000, 'No please', '+7-952-555-1784');

INSERT INTO customers (fio, birth_year, experience, phone) VALUES
('Lyuba', 2000, 'Good', '+7-908-555-1020'),
('Alis', 2000, 'Aweesome', '+7-952-555-4918'),
('Nastya', 2000, 'Super', '+7-952-555-4987'),
('Anton', 2000, 'Poor', '+7-908-555-3222'),
('Ignat', 2000, 'Awful', '+7-904-555-4453'),
('Bogdan', 2000, 'Cool', '+7-952-555-4998'),
('Maxim', 2000, 'Flex', '+7-953-555-9155'),
('Sasha', 2000, 'Idk', '+7-909-555-9811'),
('Ed', 2000, 'Ok', '+7-951-555-5456'),
('John', 2000, 'No please', '+7-909-555-6941');

INSERT INTO activities (activity_name, labor, equipment) VALUES
('Cleaning', 'Morning', 'Mop'),
('Driving', 'Daytime', 'Car'),
('Road cleaning', 'Night', 'Clenaning car'),
('Study', 'Daytime', 'Notebook'),
('Cook dinner', 'Daytime', 'Fork'),
('Pay taxes', 'Morning', 'Money'),
('Park car', 'Evening', 'Car'),
('Babysitting', 'Night', 'Baby'),
('Dishwashing', 'Morning', 'Dish'),
('Buy food', 'Evening', 'Money');

INSERT INTO executors_customers (executor_id, customer_id) VALUES
(1, 1),
(1, 2),
(1, 3),
(2, 4),
(2, 5),
(2, 6),
(2, 7),
(5, 8),
(5, 9),
(5, 10);

INSERT INTO executors_activities (executor_id, activity_id) VALUES
(1, 1),
(1, 2),
(1, 3),
(2, 4),
(2, 5),
(2, 6),
(2, 7),
(5, 8),
(5, 9),
(5, 10);

INSERT INTO customers_activities (customer_id, activity_id) VALUES
(1, 1),
(1, 2),
(1, 3),
(2, 4),
(2, 5),
(2, 6),
(2, 7),
(5, 8),
(5, 9),
(5, 10);

-- 2
-- 2.1. Инструкция SELECT, использующая предикат сравнения.
-- Вывести имена и телефоны исполнителей, стаж которых равен 'Aweesome' или 'Cool'.
SELECT fio, phone, experience FROM executors WHERE experience = 'Aweesome' OR experience = 'Cool';

-- 2.2. Инструкцию, использующую оконную функцию.
-- Вывести в дополнение к таблице столбец с количеством исполнителей с таким же опытом.
SELECT DISTINCT fio, phone, experience, COUNT(experience) OVER(PARTITION BY experience) AS same_exp_count FROM executors;

-- 2.3. Инструкция SELECT, использующая вложенные коррелированные
-- подзапросы в качестве производных таблиц в предложении FROM.
-- Вывести ФИО, телефон, опыт и дату рождения исполнителей, являющихся по совместительству заказчиками.
-- (запрос притянутый за уши, чтобы не мучиться с кучей джоинов и добавлением латерального, считал,
-- что исполнитель является и заказчиком если совпадают имена).
SELECT exs.fio, exs.phone, exs.experience, exiscust.birth_year FROM executors exs 
JOIN LATERAL (SELECT fio, phone, experience, birth_year FROM customers WHERE fio = exs.fio) exiscust
ON exiscust.fio = exs.fio;

-- 3
-- Создать хранимую процедуру с двумя входными параметрами – имя базы
-- данных и имя таблицы, которая выводит сведения об индексах указанной
-- таблицы в указанной базе данных. Созданную хранимую процедуру
-- протестировать.
CREATE OR REPLACE PROCEDURE get_indexes_info(tblname VARCHAR)
AS $$
DECLARE
    rec RECORD;
    cur CURSOR FOR
        SELECT pind.indexname, pind.indexdef FROM pg_indexes pind 
        WHERE pind.schemaname = 'public' AND pind.tablename = tblname
        ORDER BY pind.indexname;
BEGIN
    OPEN cur;
    LOOP
        FETCH cur INTO rec;
        RAISE NOTICE 'TABLE: %, INDEX: %s, DEFINITION: %', tblname, rec.indexname, rec.indexdef;
        EXIT WHEN NOT FOUND;
    END LOOP;
    CLOSE cur;
END;
$$ LANGUAGE PLPGSQL;
CALL get_indexes_info('executors');
CALL get_indexes_info('customers');
CALL get_indexes_info('activities');
