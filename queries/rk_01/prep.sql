CREATE TABLE Drivers (
    DriverID INT PRIMARY KEY,
    DriverLicense VARCHAR,
    FIO VARCHAR,
    Phone VARCHAR
);
INSERT INTO Drivers (DriverID, DriverLicense, FIO, Phone) VALUES
(1, 'Good', 'Romanov', 'phone'),
(2, 'Good', 'Kononenko', 'phone'),
(3, 'Good', 'Nitenko', 'phone'),
(4, 'Good', 'Bogachenko', 'phone');

CREATE TABLE Cars (
    CarID INT PRIMARY KEY,
    Model VARCHAR,
    Color VARCHAR,
    Year INT,
    RegistrationDate DATE
);
INSERT INTO Cars (CarID, Model, Color, Year, RegistrationDate) VALUES
(1, 'Hyundai', 'white', 2018, '2000-01-01'),
(2, 'Mazda', 'black', 2018, '2000-01-01'),
(3, 'Ferrari', 'red', 2018, '2000-01-01'),
(4, 'Lambo', 'yellow', 2018, '2000-01-01');

CREATE TABLE DC (
    CarID INT,
    DriverID INT
);
INSERT INTO DC (CarID, DriverID) VALUES
(3, 1),
(3, 2),
(3, 3);
