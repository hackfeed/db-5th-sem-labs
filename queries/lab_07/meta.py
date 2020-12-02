menumsg = "\
*** LINQ TO OBJECT: \n\
1. SELECT neighbourhood FROM neighbourhoods WHERE rating = 2.3\n\
2. SELECT host_name, price FROM listings WHERE price < 80 ORDER BY price\n\
3. SELECT AVG(price) AS avgprice, room_type FROM listings GROUP BY room_type\n\
4. SELECT COUNT(*) AS cpr FROM listings WHERE room_type = 'Private room'\n\
5. SELECT name, price FROM listings WHERE number_of_reviews > 100 ORDER BY price\n\n\
*** LINQ TO JSON\n\
6. SELECT context->'houses' houses FROM neighbourhoods\n\
7. UPDATE neighbourhoods SET context = context || '{\"houses\": 50}\n\n\
*** LINQ TO SQL\n\
8. SELECT neighbourhood FROM neighbourhoods\n\
9. SELECT reviewer_name FROM reviews r JOIN listings l ON l.id = r.listing_id WHERE l.host_name = r.reviewer_name\n\
10. INSERT INTO neighbourhoods VALUES ('Moscow', 10, 'Sergey', 'cool', '{\"houses\": 10})\n\
11. UPDATE neighbourhoods SET rating = 10 WHERE chairman = 'Joseph'\n\
12. DELETE FROM neighbourhoods WHERE chairman = 'Sergey'\n\
13. SELECT * FROM find_host_listings('David')\n\n\
0. Exit\n"

menudict = {
    1: "SELECT neighbourhood FROM neighbourhoods WHERE rating = 2.3",
    2: "SELECT host_name, price FROM listings WHERE price < 80 ORDER BY price",
    3: "SELECT AVG(price) AS avgprice, room_type FROM listings GROUP BY room_type",
    4: "SELECT COUNT(*) AS cpr FROM listings WHERE room_type = 'Private room'",
    5: "SELECT name, price FROM listings WHERE number_of_reviews > 100 ORDER BY price",
    6: "SELECT context->'houses' houses FROM neighbourhoods",
    7: "UPDATE neighbourhoods SET context = context || '{\"houses\": 50}",
    8: "SELECT neighbourhood FROM neighbourhoods",
    9: "SELECT reviewer_name FROM reviews r JOIN listings l ON l.id = r.listing_id WHERE l.host_name = r.reviewer_name",
    10: "INSERT INTO neighbourhoods VALUES ('Moscow', 10, 'Sergey', 'cool', '{\"houses\": 10})",
    11: "UPDATE neighbourhoods SET rating = 10 WHERE chairman = 'Joseph'",
    12: "DELETE FROM neighbourhoods WHERE chairman = 'Sergey'",
    13: "SELECT * FROM find_host_listings('David')",
}
