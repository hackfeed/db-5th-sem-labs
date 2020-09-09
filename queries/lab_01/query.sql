DROP DATABASE IF EXISTS dbcourse;
CREATE DATABASE dbcourse;
\c dbcourse;

CREATE TABLE neighbourhoods (
    neighbourhood VARCHAR PRIMARY KEY,
    rating DECIMAL(4,2) NOT NULL,
    chairman VARCHAR NOT NULL
);
COPY neighbourhoods FROM '/dbdata/neighbourhoods.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE listings (
    id INT PRIMARY KEY, 
    name VARCHAR, 
    host_id INT, 
    host_name VARCHAR, 
    neighbourhood VARCHAR, 
    latitude DECIMAL(16,14),  
    longitude DECIMAL(16,14), 
    room_type VARCHAR, 
    price DECIMAL(6,2), 
    minimum_nights INT, 
    number_of_reviews INT, 
    last_review DATE, 
    reviews_per_month DECIMAL(5,2), 
    calculated_host_listings_count INT, 
    availability_365 INT, 
    FOREIGN KEY (neighbourhood) REFERENCES neighbourhoods(neighbourhood) ON DELETE CASCADE
);
COPY listings FROM '/dbdata/listings.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE reviews (
    listing_id INT NOT NULL, 
    id INT PRIMARY KEY, 
    date DATE NOT NULL, 
    reviewer_id INT NOT NULL, 
    reviewer_name VARCHAR NOT NULL, 
    comments VARCHAR NOT NULL, 
    FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE
);
COPY reviews FROM '/dbdata/reviews.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE calendar (
    listing_id INT NOT NULL, 
    date DATE NOT NULL, 
    available bool NOT NULL, 
    price DECIMAL(6,2), 
    FOREIGN KEY (listing_id) REFERENCES listings(id) ON DELETE CASCADE
);
COPY calendar FROM '/dbdata/calendar.csv' DELIMITER ',' CSV HEADER;