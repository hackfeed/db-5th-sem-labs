-- Страница 9.

-- DC - развязочная таблица вида |CarID|DriverID|.

-- 1.1. Найти все пары вида <ФИО водителя, дата регистрации его автомобиля>.
-- SQL:
SELECT Drivers.FIO, Cars.RegistrationDate FROM
Drivers D JOIN DC on D.DriverID = DC.DriverID
JOIN Cars C on DC.CarID = C.CarID;
-- РА:
(Drivers JOIN DC JOIN Cars)[FIO, RegistrationDate]
-- ИК:
RANGE OF DX IS Drivers
RANGE OF DCX IS DC
RANGE OF CX IS Cars
(DX.FIO, CX.RegistrationDate) WHERE EXISTS DX (DX.DriverID = DCX.DriverID AND EXISTS CX (CX.CarID = DCX.CarID))

-- 1.2. Найти телефоны водителей, у которых есть белая машина 2018 года выпуска.
-- SQL:
SELECT Drivers.Phone FROM Drivers
JOIN DC ON DC.DriverID = Drivers.DriverID
JOIN Cars ON Cars.CarID = DC.CarID WHERE 
Cars.Color = 'Б' AND Cars.Year = 2018;
-- РА:
(((Cars WHERE Color = 'Б' AND Year = 2018) JOIN DC) JOIN Drivers)[Phone]
-- ИК:
RANGE OF DX IS Drivers
RANGE OF DCX IS DC
RANGE OF CX IS Cars
DX.Phone WHERE EXISTS CX (
    EXISTS DCX (
        CX.Color = 'Б' AND CX.Year = 2018 AND CX.CarID = DCX.CarID AND DX.DriverID = DCX.DriverID
    )
)

-- 1.3. Найти машины, которыми владеют более 2х водителей.
-- SQL:
SELECT CarID FROM DC GROUP BY CarID HAVING COUNT(*) > 2;
-- РА:
(((SUMMARIZE DC PER DC{CarID} ADD COUNT AS CNT)[CarID, CNT]) WHERE CNT > 2)[CarID]
-- ИК:
RANGE OF DCX IS DC
RANGE OF DCY IS DC
RANGE OF CX IS Cars
DCX WHERE COUNT(DCY WHERE DCY.CarID = CX.CarID) > 2

-- 2. Пусть R(A, B, C, D, E, F) – переменная отношения. F{A->BC, AC->DE, D->F, E->AB}– множество
-- функциональных зависимостей, заданных для R. Найти минимальное покрытие для заданного
-- множетва функциональных зависимостей.
R(A, B, C, D, E, F)
F {
    A -> BC, -- Декомпозиция.
    AC -> DE, -- Декомпозиция.
    D -> F,
    E -> AB -- Декомпозиция.
}
F {
    A -> B, -- См. ниже.
    A -> C,
    AC -> D,
    AC -> E, -- A -> E и E -> B => A -> B можно вычеркнуть.
    D -> F,
    E -> A,
    E -> B
}
F {
    A -> C,
    A -> D,
    A -> E,
    D -> F,
    E -> A,
    E -> B
}