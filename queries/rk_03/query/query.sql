-- Тема: РК3 Кононенко ИУ7-53Б
-- Тело: Вариант 4 + файлы

DROP DATABASE IF EXISTS rk3;
CREATE DATABASE rk3;
\c rk3;

CREATE TABLE employee (
    id SERIAL PRIMARY KEY,
    fio VARCHAR NOT NULL,
    dob DATE NOT NULL,
    dep VARCHAR NOT NULL
);

CREATE TABLE inout (
    empid INT NOT NULL,
    evdate DATE NOT NULL,
    evday VARCHAR NOT NULL,
    evtime TIME NOT NULL,
    evtype INT NOT NULL,
    FOREIGN KEY (empid) REFERENCES employee(id) ON DELETE CASCADE
);

INSERT INTO employee (fio, dob, dep) VALUES
('Иванов Иван Иванович', '1990-09-25', 'ИТ'),
('Петров Петр Петрович', '1987-11-12', 'Бухгалтерия'),
('Кононенко Сергей Сергеевич', '2000-03-04', 'Клининг'),
('Романов Алексей Васильевич', '2000-11-06', 'Бухгалтерия');

INSERT INTO inout (empid, evdate, evday, evtime, evtype) VALUES
(1, '2018-12-14', 'Суббота', '9:00', 1),
(1, '2018-12-14', 'Суббота', '9:20', 2),
(1, '2018-12-14', 'Суббота', '9:25', 1),
(2, '2018-12-14', 'Суббота', '9:05', 1);

CREATE OR REPLACE FUNCTION get_skippers(todaydate DATE)
RETURNS TABLE (
    fio VARCHAR,
    dep VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT emp.fio, emp.dep FROM employee emp WHERE emp.fio NOT IN (
        SELECT DISTINCT e.fio FROM employee e JOIN inout i ON e.id = i.empid 
        WHERE i.evdate = todaydate AND i.evtype = 1
    );
END;
$$ LANGUAGE PLPGSQL;
SELECT * FROM get_skippers('2018-12-14');

--------- 1.
SELECT DISTINCT e.fio FROM employee e JOIN inout i ON e.id = i.empid
WHERE i.evdate = '2018-12-14' AND i.evtype = 1 AND DATE_PART('minute', i.evtime::TIME - '9:00'::TIME) < 5;
--------- 2.
SELECT DISTINCT e.fio FROM employee e JOIN inout i ON e.id = i.empid
WHERE i.evdate = '2018-12-14' AND i.evtype = 2 AND i.evtime - LAG(i.evtime) OVER (PARTITION BY i.evtime) > 10;
--------- 3.
SELECT DISTINCT e.fio, e.dep FROM employee e JOIN inout i on e.id = i.empid
WHERE e.dep = 'Бухгалтерия' AND i.evtype = 1 AND i.evtime < '8:00'::TIME;